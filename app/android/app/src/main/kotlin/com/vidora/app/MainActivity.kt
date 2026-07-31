package com.vidora.app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * Bridges Android's share sheet to the Flutter side.
 *
 * The manifest has declared an `ACTION_SEND` filter for `text/plain` since
 * the platform scaffolding went in, so "Share with Vidora" already opened
 * the app — and the shared text was then dropped, because nothing read the
 * intent. This class is that missing read.
 *
 * Two paths, because Android has two:
 *  - cold start: the share created the activity, so the intent is waiting
 *    in `getIntent()` when Flutter asks for it;
 *  - warm start: the activity was already alive and gets `onNewIntent`,
 *    with no chance to ask — so it is pushed over an event channel.
 *
 * The text is passed through untouched. Parsing it, validating it and
 * deciding whether it may be downloaded all happen on the Dart side and
 * then on the server: a shared link is attacker-controlled input, and
 * native code is the last place that should be making that call.
 */
class MainActivity : FlutterActivity() {
    private var pendingSharedText: String? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        pendingSharedText = sharedTextOf(intent)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "initialSharedText" -> {
                        // Consumed on read: without this, every hot restart
                        // would re-deliver the same share and re-open Analyze
                        // on a link the user already dealt with.
                        result.success(pendingSharedText)
                        pendingSharedText = null
                    }
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        eventSink = events
                    }

                    override fun onCancel(arguments: Any?) {
                        eventSink = null
                    }
                },
            )
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val text = sharedTextOf(intent) ?: return
        // If Dart has not subscribed yet (a share landing during startup),
        // hold it for the initialSharedText call instead of dropping it.
        val sink = eventSink
        if (sink != null) sink.success(text) else pendingSharedText = text
    }

    private fun sharedTextOf(intent: Intent?): String? {
        if (intent == null || intent.action != Intent.ACTION_SEND) return null
        if (intent.type != "text/plain") return null
        return intent.getStringExtra(Intent.EXTRA_TEXT)
    }

    private companion object {
        const val METHOD_CHANNEL = "app.vidora/shared_link"
        const val EVENT_CHANNEL = "app.vidora/shared_link_events"
    }
}
