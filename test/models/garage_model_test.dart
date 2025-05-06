import 'package:flutter_test/flutter_test.dart';

import 'package:moto_mecanico/models/motorcycle.dart';
import 'package:moto_mecanico/models/garage_model.dart';

void main() {
  group('Garage Model Tests', () {
    test('adding a motorcycle generates notification', () {
      final garage = GarageModel();
      expect(garage.motos.isEmpty, true);

      var i = 0;
      garage.addListener(() {
        expect(garage.motos.isNotEmpty, true);
        i++;
      });
      garage.add(Motorcycle(name: 'Name'));
      expect(i, 1);
    });

    test('removing a motorcycle generates notification', () {
      final garage = GarageModel();
      expect(garage.motos.isEmpty, true);

      var moto = Motorcycle(name: 'Name');
      garage.add(moto);
      expect(garage.motos.isNotEmpty, true);

      garage.addListener(() {
        expect(garage.motos.isEmpty, true);
      });
      garage.remove(moto);
    });
  });
}
