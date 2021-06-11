import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
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
    @required this.name,
    this.id,
    this.odometer = const Distance(null, DistanceUnit.UnitKM),
    this.make,
    this.model,
    this.year,
    this.color,
    this.immatriculation,
    this.vin,
    this.purchasePrice,
    this.purchaseDate,
    this.purchaseOdometer = const Distance(null, DistanceUnit.UnitKM),
    this.picture,
    this.notes,
    this.attachments,
    tasks,
  }) : assert(name != null) {
    id ??= Uuid().v4();
    _tasks = tasks ?? [];
    notes ??= [];
    attachments ??= [];
  }

  MotorcycleStorage _storage;

  String name;
  String id; // Unique id
  Distance odometer;

  String make;
  String model;
  int year;
  String color;
  String immatriculation;
  String vin; // Usually 17 characters, could also be less for older models

  int purchasePrice;
  DateTime purchaseDate;
  Distance purchaseOdometer;

  String picture; // The name of the file that contains the picture
  List<Note> notes;
  List<Attachment> attachments;

  List<Task> _tasks;

  UnmodifiableListView<Task> get tasks => UnmodifiableListView(_tasks);

  MotorcycleStorage get storage => _storage;
  set storage(MotorcycleStorage storage) => _storage = storage;

  // Should be called once updating properties is over. Will trigger screen
  // updates and storage.
  void saveChanges() {
    // FIXME: Track changes and notify only if there were changes
    notifyListeners();
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
    return _tasks?.where((task) => !(task.closed ?? false))?.toList() ?? [];
  }

  List<Task> get closedTasks {
    return _tasks?.where((task) => task.closed ?? false)?.toList() ?? [];
  }

  String get description {
    final elements = <String>[year?.toString(), make, model];
    return elements.where((elem) => elem?.isNotEmpty ?? false).join(' ');
  }

  bool matches(String desc) {
    assert(desc != null);
    if (desc.isEmpty) return true;

    var upperDesc = desc.toUpperCase();
    if ([name, color, make, model].any((item) {
          return item?.toUpperCase()?.contains(upperDesc) ?? false;
        }) ==
        true) return true;

    return (notes.any((note) {
      return note.text.toUpperCase().contains(upperDesc) ||
          note.name.toUpperCase().contains(upperDesc);
    }));
  }

  factory Motorcycle.fromJson(Map<String, dynamic> json) {
    if (json != null && json['name'] != null && json['id'] != null) {
      final moto = Motorcycle(
        name: json['name'],
        id: json['id'],
        odometer: Distance.fromJson(json['odometer']),
        make: json['make'],
        model: json['model'],
        year: json['year'] as int,
        color: json['color'],
        immatriculation: json['immatriculation'],
        vin: json['vin'],
        purchasePrice: json['purchasePrice'],
        purchaseOdometer: Distance.fromJson(json['purchaseOdometer']),
        picture: json['picture'],
      );

      if (json['purchaseDate'] != null) {
        moto.purchaseDate = DateTime.tryParse(json['purchaseDate']);
      }

      if (json['notes'] != null) {
        json['notes'].forEach((n) {
          final note = Note.fromJson(n);
          if (note != null) moto.notes.add(note);
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
    data['odometer'] = odometer.toJson();

    data['make'] = make;
    data['model'] = model;
    data['year'] = year;
    data['color'] = color;
    data['immatriculation'] = immatriculation;
    data['vin'] = vin;

    data['purchasePrice'] = purchasePrice;
    if (purchaseDate != null) {
      data['purchaseDate'] = purchaseDate.toIso8601String();
    }
    if (purchaseOdometer != null) {
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
  bool operator ==(dynamic other) {
    return other is Motorcycle && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  static Future<Motorcycle> fromMotorcycle(
      Motorcycle other, MotorcycleStorage storage) async {
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

    if (other.picture != null) {
      final orig = await other.storage.getMotoFile(other.picture);
      moto.picture = await storage.addMotoFile(orig.path);
    }

    for (final note in other.notes) {
      moto.notes.add(Note.from(note));
    }

    for (final attachment in other.attachments) {
      var url = attachment.url;
      if (attachment.type == AttachmentType.file ||
          attachment.type == AttachmentType.picture) {
        final orig = await other.storage.getMotoFile(attachment.url);
        url = await storage.addMotoFile(orig.path);
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
      await Task.transferAttachments(
          newTask, other.storage.storage, storage.storage);
      moto.addTask(newTask);
    }

    return moto;
  }
}
