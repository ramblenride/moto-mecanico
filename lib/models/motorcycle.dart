import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:moto_mecanico/models/attachment.dart';
import 'package:moto_mecanico/models/distance.dart';
import 'package:moto_mecanico/models/note.dart';
import 'package:moto_mecanico/models/task.dart';
import 'package:moto_mecanico/storage/motorcycle_storage.dart';
import 'package:uuid/uuid.dart';

// Defines a motorcycle. All objects are optional except for the name.
// The name doesn't have to be unique across motorcycles, only the id is unique.
class Motorcycle with ChangeNotifier {
  Motorcycle({
    required this.name,
    String? id,
    this.odometer = const Distance(null, DistanceUnit.unitKm),
    this.make = '',
    this.model = '',
    this.year,
    this.color = '',
    this.immatriculation = '',
    this.vin = '',
    this.purchasePrice,
    this.purchaseDate,
    this.purchaseOdometer = const Distance(null),
    this.picture = '',
    List<Note>? notes,
    List<Attachment>? attachments,
    List<Task>? tasks,
  })  : id = id ?? const Uuid().v4(),
        notes = notes ?? [],
        attachments = attachments ?? [],
        _tasks = tasks ?? [] {
    // Initialize the saved state for tracking changes
    _lastSavedName = name;
    _lastSavedId = this.id;
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
  final String id; // Unique id
  Distance odometer;

  String make;
  String model;
  int? year;
  String color;
  String immatriculation;
  String vin; // Usually 17 characters but could also be less for older models

  int? purchasePrice;
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
  // FIXME: This is a bit clunky. Would be better to have individual setters
  // that trigger notifyListeners() and storage updates directly.
  // FIXME: Not all properties are tracked, only the most important ones.
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
      throw ArgumentError('Task already exists');
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

  factory Motorcycle.fromJson(Map<String, dynamic> json) {
    if (json['name'] == null || json['id'] == null) {
      throw ArgumentError('Invalid motorcycle JSON: missing name or id');
    }

    final moto = Motorcycle(
      name: json['name'],
      id: json['id'],
      odometer: Distance.fromJson(json['odometer']),
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] is int ? json['year'] as int : null,
      color: json['color'] ?? '',
      immatriculation: json['immatriculation'] ?? '',
      vin: json['vin'] ?? '',
      purchasePrice:
          json['purchasePrice'] is int ? json['purchasePrice'] as int : null,
      purchaseOdometer: Distance.fromJson(json['purchaseOdometer']),
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
        try {
          final attachment = Attachment.fromJson(a);
          moto.attachments.add(attachment);
        } catch (e) {
          debugPrint("Ignoring invalid attachment JSON: $e");
        }
      });
    }

    if (json['tasks'] != null) {
      json['tasks'].forEach((t) {
        try {
          final task = Task.fromJson(t);
          moto._tasks.add(task);
        } catch (e) {
          debugPrint("Ignoring invalid task JSON: $e");
        }
      });
    }

    return moto;
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

    if (purchasePrice != null) {
      data['purchasePrice'] = purchasePrice;
    }
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
      moto.notes.add(note.copyWith());
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
