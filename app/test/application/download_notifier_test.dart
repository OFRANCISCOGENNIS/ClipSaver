/// What the queue is allowed to interrupt the user about.
///
/// The rules under test are product decisions, not plumbing: notify on
/// outcomes the user cannot see coming, stay quiet about anything the
/// scheduler will fix by itself, and never say the same thing twice.
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/core/domain/value_objects/file_size.dart';
import 'package:vidora/core/platform/notification_port.dart';
import 'package:vidora/features/downloads/application/download_notifier.dart';
import 'package:vidora/features/downloads/domain/download_state.dart';
import 'package:vidora/features/downloads/domain/download_task.dart';
import 'package:vidora/features/settings/domain/app_settings.dart';

import '../support/download_fakes.dart';
import '../support/fake_notification_port.dart';
import '../support/in_memory_download_repository.dart';
import '../support/in_memory_settings_repository.dart';

void main() {
  late InMemoryDownloadRepository repository;
  late InMemorySettingsRepository settings;
  late FakeNotificationPort port;
  late DownloadNotifier notifier;

  /// Feeds the notifier by hand, which is what the manager does when a
  /// task reaches a state the scheduler will not act on again.
  late void Function(DownloadTask task) emit;

  void build([AppSettings initial = const AppSettings()]) {
    repository = InMemoryDownloadRepository();
    settings = InMemorySettingsRepository(initial);
    port = FakeNotificationPort();
    final controller = StreamController<DownloadTask>.broadcast();
    emit = controller.add;
    notifier = DownloadNotifier(
      terminalUpdates: controller.stream,
      repository: repository,
      settings: settings,
      port: port,
    );
    addTearDown(() async {
      notifier.dispose();
      await controller.close();
      await settings.dispose();
      await repository.dispose();
    });
  }

  DownloadTask done(String id, String title) =>
      taskFixture(id: id, title: title).copyWith(
          totalBytes: FileSize.ofBytes(10), state: DownloadState.done);

  DownloadTask failed(String id, String title, String reason) =>
      taskFixture(id: id, title: title)
          .copyWith(state: DownloadState.failed, failureReason: reason);

  /// Lets the notifier's async handler run to completion.
  Future<void> drain() => Future<void>.delayed(Duration.zero);

  test('um download concluído vira uma notificação com o título', () async {
    build();
    await repository.save(done('t1', 'Aula aberta'));

    emit(done('t1', 'Aula aberta'));
    await drain();

    expect(port.kinds, [SystemNotificationKind.downloadDone]);
    expect(port.shown.single.title, contains('Aula aberta'));
  });

  test('uma falha leva o motivo junto: "falhou" sozinho não ajuda ninguém',
      () async {
    build();
    await repository.save(failed('t1', 'Aula', 'Conexão perdida'));

    emit(failed('t1', 'Aula', 'Conexão perdida'));
    await drain();

    expect(port.kinds, [SystemNotificationKind.downloadFailed]);
    expect(port.shown.single.body, 'Conexão perdida');
  });

  test('um único download não gera também o aviso de fila terminada', () async {
    build();
    await repository.save(done('t1', 'Aula'));

    emit(done('t1', 'Aula'));
    await drain();

    // "Aula concluída" seguido de "todos os downloads terminaram" diz a
    // mesma coisa duas vezes, e quem repete acaba silenciado pelo usuário.
    expect(port.kinds, [SystemNotificationKind.downloadDone]);
  });

  test('dois downloads terminando fecham a fila com um aviso só', () async {
    build();
    await repository.save(done('t1', 'Primeiro'));
    await repository.save(
      taskFixture(id: 't2', title: 'Segundo')
          .copyWith(state: DownloadState.queued),
    );

    emit(done('t1', 'Primeiro'));
    await drain();
    // Ainda há um item na fila: nada de "terminou tudo".
    expect(port.kinds, [SystemNotificationKind.downloadDone]);

    await repository.save(done('t2', 'Segundo'));
    emit(done('t2', 'Segundo'));
    await drain();

    expect(port.kinds, [
      SystemNotificationKind.downloadDone,
      SystemNotificationKind.downloadDone,
      SystemNotificationKind.queueFinished,
    ]);
  });

  test('um item pausado não segura o aviso de fila terminada', () async {
    build();
    await repository.save(done('t1', 'Primeiro'));
    await repository.save(
      taskFixture(id: 't2', title: 'Segundo')
          .copyWith(state: DownloadState.queued),
    );
    await repository.save(
      taskFixture(id: 't3', title: 'Parado')
          .copyWith(state: DownloadState.paused),
    );

    emit(done('t1', 'Primeiro'));
    await drain();
    await repository.save(done('t2', 'Segundo'));
    emit(done('t2', 'Segundo'));
    await drain();

    // Sobra o 't3' pausado, e mesmo assim a fila conta como terminada: o
    // usuário pausou de propósito, então "tudo o que você pediu terminou"
    // continua verdade.
    expect(port.kinds.last, SystemNotificationKind.queueFinished);
  });

  group('estilo escolhido em Ajustes', () {
    for (final caso in [
      (NotificationStyle.sound, NotificationDelivery.sound),
      (NotificationStyle.vibrate, NotificationDelivery.vibrationOnly),
      (NotificationStyle.silent, NotificationDelivery.silent),
    ]) {
      test('${caso.$1.name} entrega como ${caso.$2.name}', () async {
        build(AppSettings(notificationStyle: caso.$1));
        await repository.save(done('t1', 'Aula'));

        emit(done('t1', 'Aula'));
        await drain();

        expect(port.shown.single.delivery, caso.$2);
      });
    }
  });

  group('idioma', () {
    for (final caso in [
      (AppLanguage.ptBr, 'concluído'),
      (AppLanguage.en, 'finished'),
      (AppLanguage.es, 'completado'),
    ]) {
      test('a notificação sai em ${caso.$1.code}', () async {
        build(AppSettings(language: caso.$1));
        await repository.save(done('t1', 'Aula'));

        emit(done('t1', 'Aula'));
        await drain();

        // O idioma é o do app, não o do aparelho: uma notificação em outra
        // língua que a interface parece vir de outro programa.
        expect(port.shown.single.title, contains(caso.$2));
      });
    }
  });
}
