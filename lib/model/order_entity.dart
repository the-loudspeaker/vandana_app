class Order {
  final String id;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String customerName;
  final String? customerContact;
  final String? customerAddress;
  final String model;
  final String issueDescription;
  final num estimatedCost;
  final num? actualCost;
  final num advanceAmount;
  final String remarks;
  final String status;
  final String screenlockType;
  final String screenlock;
  final int jobId;
  final List<String> itemsList;
  final String poc;

  Order({
    required this.id,
    required this.createdAt,
    required this.modifiedAt,
    required this.customerName,
    this.customerContact,
    this.customerAddress,
    required this.model,
    required this.issueDescription,
    required this.estimatedCost,
    this.actualCost,
    required this.advanceAmount,
    required this.remarks,
    required this.status,
    required this.screenlockType,
    required this.screenlock,
    required this.jobId,
    required this.itemsList,
    required this.poc,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      modifiedAt: DateTime.parse(map['modified_at']),
      customerName: map['customer_name'],
      customerContact: map['customer_contact'],
      customerAddress: map['customer_address'],
      model: map['model'],
      issueDescription: map['issue_description'],
      estimatedCost: map['estimated_cost']??0,
      actualCost: map['actual_cost'],
      advanceAmount: map['advance_amount']??0,
      remarks: map['remarks'],
      status: map['status'],
      screenlockType: map['screenlock_type'],
      screenlock: map['screenlock'],
      jobId: map['job_id'],
      itemsList: List<String>.from(map['items_list']),
      poc: map['poc'],
    );
  }

  static List<Order> fromList(List<Map<String, dynamic>> list) {
    return list.map((map) => Order.fromMap(map)).toList();
  }
}