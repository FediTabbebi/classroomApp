class RoleModel {
  String id;
  String label;

  RoleModel({
    required this.id,
    required this.label,
  });

  // Factory constructor to create a RoleModel from a map
  factory RoleModel.fromMap(Map<String, dynamic> map) {
    return RoleModel(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
    );
  }

  // Method to convert RoleModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
    };
  }
}
