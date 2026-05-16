library;

/// Modele d'entreprise recruteuse avec ses offres.

class CompanyModel {
  final String id;
  final String name;
  final String sector;
  final String city;
  final String description;
  final String? logoUrl;
  final List<OfferModel> offers;

  String get initials => name.length >= 2
      ? name.substring(0, 2).toUpperCase()
      : name.toUpperCase();

  const CompanyModel({
    required this.id,
    required this.name,
    required this.sector,
    required this.city,
    required this.description,
    this.logoUrl,
    required this.offers,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      sector: json['sector'] as String,
      city: json['city'] as String,
      description: json['description'] as String,
      logoUrl: json['logo_url'] as String?,
      offers: (json['offers'] as List?)
              ?.map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class OfferModel {
  final String id;
  final String title;
  final String companyName;
  final String sector;
  final String city;
  final String contractType;
  final String? mediaUrl;
  final String mediaType; // 'image' ou 'video'
  final String? description;
  final String? recruiterId;

  const OfferModel({
    required this.id,
    required this.title,
    required this.companyName,
    required this.sector,
    required this.city,
    required this.contractType,
    this.mediaUrl,
    this.mediaType = 'video',
    this.description,
    this.recruiterId,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] as String,
      title: json['title'] as String,
      companyName: json['company_name'] as String,
      sector: json['sector'] as String,
      city: json['city'] as String,
      contractType: json['contract_type'] as String,
      mediaUrl: json['media_url'] as String?,
      mediaType: json['media_type'] as String? ?? 'video',
      description: json['description'] as String?,
      recruiterId: json['recruiter_id'] as String?,
    );
  }
}
