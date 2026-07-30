import 'package:flutter_test/flutter_test.dart';
import 'package:vidora/core/domain/value_objects/license.dart';

void main() {
  group('License.fromMetadata', () {
    test('maps canonical SPDX identifiers', () {
      expect(License.fromMetadata('CC-BY-4.0'), License.ccBy);
      expect(License.fromMetadata('cc-by-sa-4.0'), License.ccBySa);
      expect(License.fromMetadata('CC-BY-NC-4.0'), License.ccByNc);
      expect(License.fromMetadata('CC-BY-ND-4.0'), License.ccByNd);
      expect(License.fromMetadata('CC0-1.0'), License.cc0);
      expect(License.fromMetadata('PDM'), License.publicDomain);
    });

    test('maps Creative Commons license URLs', () {
      expect(
        License.fromMetadata('https://creativecommons.org/licenses/by/4.0/'),
        License.ccBy,
      );
      expect(
        License.fromMetadata('https://creativecommons.org/licenses/by-sa/4.0/'),
        License.ccBySa,
      );
      expect(
        License.fromMetadata(
          'https://creativecommons.org/publicdomain/zero/1.0/',
        ),
        License.cc0,
      );
    });

    test('fails closed: null or unknown strings mean all rights reserved', () {
      expect(License.fromMetadata(null), License.allRightsReserved);
      expect(
        License.fromMetadata('Standard License'),
        License.allRightsReserved,
      );
      expect(License.fromMetadata(''), License.allRightsReserved);
      expect(License.allRightsReserved.allowsDownload, isFalse);
    });

    test('open licenses allow download and expose restrictions', () {
      expect(License.ccBy.allowsDownload, isTrue);
      expect(
        License.ccBy.restrictions,
        contains(LicenseRestriction.attribution),
      );
      expect(
        License.ccByNc.restrictions,
        contains(LicenseRestriction.nonCommercial),
      );
      expect(License.cc0.restrictions, isEmpty);
    });
  });
}
