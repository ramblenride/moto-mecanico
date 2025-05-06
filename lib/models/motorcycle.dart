import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:moto_mecanico/models/attachment.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:moto_mecanico/models/note.dart';
import 'package:moto_mecanico/models/task.dart';
import 'package:moto_mecanico/storage/motorcycle_storage.dart';
import 'package:uuid/uuid.dart';

// Defines a motorcycle. All objects are optional except for the name.
// The name doesn't have to be unique across motorcycles.
class Motorcycle extends ChangeNotifier {
  Motorcycle({
    required this.name,
    this.id = '',
    this.odometer = const Distance(null, DistanceUnit.unitKm),
    this.make = '',
    this.model = '',
    this.year,
    this.color = '',
    this.immatriculation = '',
    this.vin = '',
    this.purchasePrice = 0,
    this.purchaseDate,
    this.purchaseOdometer = const Distance(null, DistanceUnit.unitKm),
    this.picture = '',
    List<Note>? notes,
    List<Attachment>? attachments,
    List<Task>? tasks,
  })  : notes = notes ?? [],
        attachments = attachments ?? [],
        _tasks = tasks ?? [] {
    if (id.isEmpty) id = const Uuid().v4();

    // Initialize the saved state for tracking changes
    _lastSavedName = name;
    _lastSavedId = id;
    _lastSavedOdometer = odometer;
    _lastSavedMake = make;
    _lastSavedModel = model;
    _lastSavedYear = year;
    _lastSavedColor = color;
    _lastSavedImmatriculation = immatriculation;
    _lastSavedVin = vin;
  }

  MotorcycleStorage? storage;

  String name;
  String id; // Unique id
  Distance odometer;

  String make;
  String model;
  int? year;
  String color;
  String immatriculation;
  String vin; // Usually 17 characters, could also be less for older models

  int purchasePrice;
  DateTime? purchaseDate;
  Distance purchaseOdometer;

  String picture; // The name of the file that contains the picture
  List<Note> notes;
  List<Attachment> attachments;

  final List<Task> _tasks;

  UnmodifiableListView<Task> get tasks => UnmodifiableListView(_tasks);

  // Fields that are tracked for changes
  String _lastSavedName = '';
  String _lastSavedId = '';
  Distance _lastSavedOdometer = const Distance(null, DistanceUnit.unitKm);
  String _lastSavedMake = '';
  String _lastSavedModel = '';
  int? _lastSavedYear;
  String _lastSavedColor = '';
  String _lastSavedImmatriculation = '';
  String _lastSavedVin = '';

  // Should be called once updating properties is over. Will trigger screen
  // updates and storage only if changes were made.
  void saveChanges() {
    // Check if any tracked properties have changed
    bool hasChanges = name != _lastSavedName ||
        id != _lastSavedId ||
        odometer != _lastSavedOdometer ||
        make != _lastSavedMake ||
        model != _lastSavedModel ||
        year != _lastSavedYear ||
        color != _lastSavedColor ||
        immatriculation != _lastSavedImmatriculation ||
        vin != _lastSavedVin;

    if (hasChanges) {
      // Update the saved state
      _lastSavedName = name;
      _lastSavedId = id;
      _lastSavedOdometer = odometer;
      _lastSavedMake = make;
      _lastSavedModel = model;
      _lastSavedYear = year;
      _lastSavedColor = color;
      _lastSavedImmatriculation = immatriculation;
      _lastSavedVin = vin;

      // Notify listeners
      notifyListeners();
    }
  }

  bool addTask(Task task) {
    if (_tasks.contains(task)) {
      return false;
    }

    _tasks.add(task);
    return true;
  }

  bool removeTask(Task task) {
    return _tasks.remove(task);
  }

  List<Task> get activeTasks {
    return _tasks.where((task) => !task.closed).toList();
  }

  List<Task> get closedTasks {
    return _tasks.where((task) => task.closed).toList();
  }

  String get description {
    final elements = <String>[year?.toString() ?? '', make, model];
    return elements.where((elem) => elem.isNotEmpty).join(' ');
  }

  bool matches(String desc) {
    if (desc.isEmpty) return true;

    var upperDesc = desc.toUpperCase();
    if ([name, color, make, model].any((item) {
          return item.toUpperCase().contains(upperDesc);
        }) ==
        true) return true;

    return (notes.any((note) {
      return note.text.toUpperCase().contains(upperDesc) ||
          note.name.toUpperCase().contains(upperDesc);
    }));
  }

  static Motorcycle? fromJson(Map<String, dynamic> json) {
    if (json['name'] != null && json['id'] != null) {
      final moto = Motorcycle(
        name: json['name'],
        id: json['id'],
        odometer: json['odometer'] != null
            ? Distance.fromJson(json['odometer'])
            : const Distance(null),
        make: json['make'] ?? '',
        model: json['model'] ?? '',
        year: json['year'] != null ? int.tryParse(json['year']) : null,
        color: json['color'] ?? '',
        immatriculation: json['immatriculation'] ?? '',
        vin: json['vin'] ?? '',
        purchasePrice: json['purchasePrice'] ?? 0,
        purchaseOdometer: json['purchaseOdometer'] != null
            ? Distance.fromJson(json['purchaseOdometer'])
            : const Distance(null),
        picture: json['picture'] ?? '',
      );

      if (json['purchaseDate'] != null) {
        moto.purchaseDate = DateTime.tryParse(json['purchaseDate']);
      }

      if (json['notes'] != null) {
        json['notes'].forEach((n) {
          final note = Note.fromJson(n);
          if (note.name.isNotEmpty || note.text.isNotEmpty) {
            moto.notes.add(note);
          }
        });
      }

      if (json['attachments'] != null) {
        json['attachments'].forEach((a) {
          final attachment = Attachment.fromJson(a);
          if (attachment != null) moto.attachments.add(attachment);
        });
      }

      if (json['tasks'] != null) {
        json['tasks'].forEach((t) {
          final task = Task.fromJson(t);
          if (task != null) moto._tasks.add(task);
        });
      }

      return moto;
    }

    return null;
  }

  Map<String, dynamic> toJson({bool encodeTasks = true}) {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['id'] = id;
    if (odometer.isValid) {
      data['odometer'] = odometer.toJson();
    }

    data['make'] = make;
    data['model'] = model;
    if (year != null) {
      data['year'] = year;
    }
    data['color'] = color;
    data['immatriculation'] = immatriculation;
    data['vin'] = vin;

    data['purchasePrice'] = purchasePrice;
    if (purchaseDate != null) {
      data['purchaseDate'] = purchaseDate?.toIso8601String();
    }
    if (purchaseOdometer.isValid) {
      data['purchaseOdometer'] = purchaseOdometer.toJson();
    }

    data['picture'] = picture;
    data['notes'] = notes.map((note) => note.toJson()).toList();
    data['attachments'] = attachments.map((v) => v.toJson()).toList();

    if (encodeTasks) {
      data['tasks'] = _tasks.map((v) => v.toJson()).toList();
    }

    return data;
  }

  @override
  bool operator ==(Object other) {
    return other is Motorcycle && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  static Future<Motorcycle> fromMotorcycle(
      Motorcycle other, MotorcycleStorage? storage) async {
    final moto = Motorcycle(
      name: other.name,
      id: other.id,
      odometer: other.odometer,
      make: other.make,
      model: other.model,
      year: other.year,
      color: other.color,
      immatriculation: other.immatriculation,
      vin: other.vin,
      purchasePrice: other.purchasePrice,
      purchaseDate: other.purchaseDate,
      purchaseOdometer: other.purchaseOdometer,
    );
    moto.storage = storage;

    for (final note in other.notes) {
      moto.notes.add(Note.from(note));
    }

    if (other.picture.isNotEmpty && storage != null && other.storage != null) {
      final orig = await other.storage!.getMotoFile(other.picture);
      if (orig != null) {
        moto.picture = await storage.addMotoFile(orig.path) ?? '';
      }
    }

    for (final attachment in other.attachments) {
      var url = attachment.url;
      if (attachment.type == AttachmentType.file ||
          attachment.type == AttachmentType.picture) {
        if (storage != null && other.storage != null) {
          final orig = await other.storage!.getMotoFile(attachment.url);
          url =
              (orig != null) ? await storage.addMotoFile(orig.path) ?? '' : '';
        } else {
          // Drop the attachment since we can't cpoy it
          url = '';
        }
      }

      final newAttachment = Attachment(
        name: attachment.name,
        type: attachment.type,
        url: url,
      );
      moto.attachments.add(newAttachment);
    }

    for (final task in other.tasks) {
      final newTask = Task.from(task, ignoreCopyable: true);
      if (storage != null && other.storage != null) {
        await Task.transferAttachments(
            newTask, other.storage!.storage, storage.storage);
      }
      moto.addTask(newTask);
    }

    return moto;
  }
}
