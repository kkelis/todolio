import 'package:flutter/material.dart';

class Brand {
  final String id;
  final String name;
  final String logoAssetPath;
  final Color primaryColor;
  final Color? secondaryColor;

  Brand({
    required this.id,
    required this.name,
    required this.logoAssetPath,
    required this.primaryColor,
    this.secondaryColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'logoAssetPath': logoAssetPath,
      'primaryColor': primaryColor.toARGB32(),
      'secondaryColor': secondaryColor?.toARGB32(),
    };
  }

  factory Brand.fromMap(Map<String, dynamic> map) {
    return Brand(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      logoAssetPath: map['logoAssetPath'] ?? '',
      primaryColor: Color(map['primaryColor'] ?? 0xFF000000),
      secondaryColor: map['secondaryColor'] != null
          ? Color(map['secondaryColor'])
          : null,
    );
  }
}

class BrandDatabase {
  static final List<Brand> _brands = [
    Brand(
      id: 'pevex',
      name: 'Pevex',
      logoAssetPath: 'assets/images/brands/pevex.svg',
      primaryColor: Color(0xFF00ab4e),
    ),
    Brand(
      id: 'froddo',
      name: 'Froddo',
      logoAssetPath: 'assets/images/brands/froddo.svg',
      primaryColor: Color(0xFF97BF0D),
    ),
    Brand(
      id: 'bio&bio',
      name: 'Bio&Bio',
      logoAssetPath: 'assets/images/brands/bio&bio.svg',
      primaryColor: Color(0xFFFFFFFF),
    ),
    Brand(
      id: 'timberland',
      name: 'Timberland',
      logoAssetPath: 'assets/images/brands/timberland.svg',
      primaryColor: Color(0xFFF5A742),
    ),
    Brand(
      id: 'multipluscard',
      name: 'Multipluscard',
      logoAssetPath: 'assets/images/brands/multipluscard.svg',
      primaryColor: Color(0xFF014d8d),
    ),
    Brand(
      id: 'xyz',
      name: 'XYZ',
      logoAssetPath: 'assets/images/brands/xyz.svg',
      primaryColor: Color(0xFFFFFFFF),
    ),
    Brand(
      id: 'towercentarrijeka',
      name: "Tower Centar Rijeka",
      logoAssetPath: 'assets/images/brands/towercentarrijeka.png',
      primaryColor: Color(0xFFD00C73),
    ),
    Brand(
      id: 'mana',
      name: 'Mana',
      logoAssetPath: 'assets/images/brands/mana.svg',
      primaryColor: Color(0xFFD7191E),
    ),

    Brand(
      id: 'peek&cloppenburg',
      name: 'Peek & Cloppenburg',
      logoAssetPath: 'assets/images/brands/peek&cloppenburg.png',
      primaryColor: Color(0xFFFFFFFF),
    ),
    Brand(
      id: 'emmezeta',
      name: "Emmezeta",
      logoAssetPath: 'assets/images/brands/emmezeta.svg',
      primaryColor: Color(0xFFE2008C),
    ),
    Brand(
      id: 'studenac',
      name: 'Studenac',
      logoAssetPath: 'assets/images/brands/studenac.svg',
      primaryColor: Color(0xFFFF6D00),
    ),
    Brand(
      id: 'metro',
      name: 'Metro',
      logoAssetPath: 'assets/images/brands/metro.svg',
      primaryColor: Color(0xFF002D72),
    ),
    Brand(
      id: 'hak',
      name: 'Hak',
      logoAssetPath: 'assets/images/brands/hak.svg',
      primaryColor: Color(0xFF00358E),
    ),
    Brand(
      id: 'tokic',
      name: "Tokić",
      logoAssetPath: 'assets/images/brands/tokic.svg',
      primaryColor: Color(0xFF004289),
    ),
    Brand(
      id: 'sport&binus',
      name: 'Sport & Binus',
      logoAssetPath: 'assets/images/brands/sport&binus.svg',
      primaryColor: Color(0xFF000000),
    ),
    Brand(
      id: 'cineplexx',
      name: "Cineplexx",
      logoAssetPath: 'assets/images/brands/cineplexx.png',
      primaryColor: Color(0xFFFFFFFF),
    ),

    Brand(
      id: 'officeshoes',
      name: 'Office Shoes',
      logoAssetPath: 'assets/images/brands/officeshoes.svg',
      primaryColor: Color(0xFF000000),
    ),
    Brand(
      id: 'dietpharm',
      name: 'Dietpharm',
      logoAssetPath: 'assets/images/brands/dietpharm.svg',
      primaryColor: Color(0xFF007A3D),
    ),
    Brand(
      id: 'ferivi',
      name: 'Ferivi',
      logoAssetPath: 'assets/images/brands/ferivi.svg',
      primaryColor: Color(0xFF000000),
    ),
    Brand(
      id: 'mojaposta',
      name: "Moja Pošta",
      logoAssetPath: 'assets/images/brands/mojaposta.png',
      primaryColor: Color(0xFFFFCB09),
    ),
    Brand(
      id: 'zdravljeplus',
      name: 'ZdravljePlus',
      logoAssetPath: 'assets/images/brands/zdravljeplus.png',
      primaryColor: Color(0xFFFFFFFF),
    ),
    Brand(
      id: 'magicbaby',
      name: 'Magic Baby',
      logoAssetPath: 'assets/images/brands/magicbaby.svg',
      primaryColor: Color(0xFF56C5D0),
    ),

    Brand(
      id: 'europa92',
      name: 'Europa92',
      logoAssetPath: 'assets/images/brands/europa92.svg',
      primaryColor: Color(0xFF000000),
    ),
    Brand(
      id: 'boso',
      name: 'Boso',
      logoAssetPath: 'assets/images/brands/boso.svg',
      primaryColor: Color(0xFF0160AF),
    ),
    Brand(
      id: 'ina',
      name: 'INA',
      logoAssetPath: 'assets/images/brands/ina.svg',
      primaryColor: Color(0xFF014C97),
    ),
    Brand(
      id: 'bipa',
      name: 'Bipa',
      logoAssetPath: 'assets/images/brands/bipa.svg',
      primaryColor: Color(0xFFEC008C),
    ),
    Brand(
      id: 'farmacia',
      name: 'Farmacia',
      logoAssetPath: 'assets/images/brands/farmacia.svg',
      primaryColor: Color(0xFF73BF44),
    ),

    Brand(
      id: 'lesnina',
      name: 'Lesnina',
      logoAssetPath: 'assets/images/brands/lesnina.svg',
      primaryColor: Color(0xFFFFF201),
    ),
    Brand(
      id: 'ktc',
      name: 'KTC',
      logoAssetPath: 'assets/images/brands/ktc.svg',
      primaryColor: Color(0xFF00874B),
    ),
    Brand(
      id: 'sportina',
      name: 'Sportina',
      logoAssetPath: 'assets/images/brands/sportina.svg',
      primaryColor: Color(0xFFFFFFFF),
    ),

    Brand(
      id: 'alpina',
      name: 'Alpina',
      logoAssetPath: 'assets/images/brands/alpina.png',
      primaryColor: Color(0xFF0D3364),
    ),
    Brand(
      id: 'arriva',
      name: 'Arriva',
      logoAssetPath: 'assets/images/brands/arriva.svg',
      primaryColor: Color(0xFF00A1AC),
    ),
    Brand(
      id: 'gant',
      name: 'Gant',
      logoAssetPath: 'assets/images/brands/gant.svg',
      primaryColor: Color(0xFF231F20),
    ),
    Brand(
      id: 'orsay',
      name: 'Orsay',
      logoAssetPath: 'assets/images/brands/orsay.svg',
      primaryColor: Color(0xFFFFFFFF),
    ),
    Brand(
      id: 'optikaanda',
      name: 'Optika Anda',
      logoAssetPath: 'assets/images/brands/optikaanda.png',
      primaryColor: Color(0xFF000000),
    ),
    Brand(
      id: 'petrol',
      name: 'Petrol',
      logoAssetPath: 'assets/images/brands/petrol.svg',
      primaryColor: Color(0xFFE30613),
    ),
    Brand(
      id: 'polleosport',
      name: 'Polleo Sport',
      logoAssetPath: 'assets/images/brands/polleosport.svg',
      primaryColor: Color(0xFF000000),
    ),
    Brand(
      id: 'lidl',
      name: 'Lidl',
      logoAssetPath: 'assets/images/brands/lidl.svg',
      primaryColor: Color(0xFF0050AA),
    ),
    Brand(
      id: 'gkzd',
      name: 'Gradska knjižnica Zadar',
      logoAssetPath: 'assets/images/brands/gkzd.png',
      primaryColor: Color(0xFFFFFFFF),
    ),
    Brand(
      id: 'petcentar',
      name: "Pet Centar",
      logoAssetPath: 'assets/images/brands/petcentar.svg',
      primaryColor: Color(0xFFE30231),
    ),
    Brand(
      id: 'ciakauto',
      name: 'Ciak Auto',
      logoAssetPath: 'assets/images/brands/ciakauto.png',
      primaryColor: Color(0xFFFFFFFF),
    ),
    Brand(
      id: 'pittarosso',
      name: 'Pittarosso',
      logoAssetPath: 'assets/images/brands/pittarosso.svg',
      primaryColor: Color(0xFFD3003B),
    ),
    Brand(
      id: 'karla',
      name: 'Karla',
      logoAssetPath: 'assets/images/brands/karla.svg',
      primaryColor: Color(0xFF1C1B19),
    ),
    Brand(
      id: 'zoocity',
      name: 'Zoocity',
      logoAssetPath: 'assets/images/brands/zoocity.svg',
      primaryColor: Color(0xFFF2F191),
    ),
    Brand(
      id: 'ikea',
      name: 'Ikea',
      logoAssetPath: 'assets/images/brands/ikea.svg',
      primaryColor: Color(0xFF0058AB),
    ),
    Brand(
      id: 'decathlon',
      name: 'Decathlon',
      logoAssetPath: 'assets/images/brands/decathlon.svg',
      primaryColor: Color(0xFF3643BA),
    ),
    Brand(
      id: 'prima',
      name: 'Prima',
      logoAssetPath: 'assets/images/brands/prima.svg',
      primaryColor: Color(0xFF393E42),
    ),
    Brand(
      id: 'babycenter',
      name: 'Baby Center',
      logoAssetPath: 'assets/images/brands/babycenter.png',
      primaryColor: Color(0xFFFFFFFF),
    ),
    Brand(
      id: 'cinestar',
      name: 'Cinestar',
      logoAssetPath: 'assets/images/brands/cinestar.svg',
      primaryColor: Color(0xFF051851),
    ),
    Brand(
      id: 'tekstilpromet',
      name: 'Tekstilpromet',
      logoAssetPath: 'assets/images/brands/tekstilpromet.svg',
      primaryColor: Color(0xFF008850),
    ),
    Brand(
      id: 'momax',
      name: 'Momax',
      logoAssetPath: 'assets/images/brands/momax.svg',
      primaryColor: Color(0xFF60AB39),
    ),
    Brand(
      id: 'hervis',
      name: 'Hervis',
      logoAssetPath: 'assets/images/brands/hervis.svg',
      primaryColor: Color(0xFF004C90),
    ),
    Brand(
      id: 'shell',
      name: 'Shell',
      logoAssetPath: 'assets/images/brands/shell.svg',
      primaryColor: Color(0xFFFFD202),
    ),
    Brand(
      id: 'dm',
      name: 'DM',
      logoAssetPath: 'assets/images/brands/dm.svg',
      primaryColor: Color(0xFF1E3685),
    ),
    Brand(
      id: 'kiehls',
      name: 'Kiehl\'s',
      logoAssetPath: 'assets/images/brands/kiehls.svg',
      primaryColor: Color(0xFF000000),
    ),
    Brand(
      id: 'soliver',
      name: 's.Oliver',
      logoAssetPath: 'assets/images/brands/soliver.svg',
      primaryColor: Color(0xFFE50041),
    ),
    Brand(
      id: 'kaufland',
      name: 'Kaufland',
      logoAssetPath: 'assets/images/brands/kaufland.svg',
      primaryColor: Color(0xFFE3000F),
    ),
    Brand(
      id: 'takko',
      name: 'Takko',
      logoAssetPath: 'assets/images/brands/takko.svg',
      primaryColor: Color(0xFFFFE600),
    ),
    Brand(
      id: 'bauhaus',
      name: 'Bauhaus',
      logoAssetPath: 'assets/images/brands/bauhaus.svg',
      primaryColor: Color(0xFFDF0023),
    ),
    Brand(
      id: 'douglas',
      name: 'Douglas',
      logoAssetPath: 'assets/images/brands/douglas.png',
      primaryColor: Color(0xFF9BDCD2),
    ),
    Brand(
      id: 'ccc',
      name: 'CCC',
      logoAssetPath: 'assets/images/brands/ccc.svg',
      primaryColor: Color(0xFF222222),
    ),
    Brand(
      id: 'diesel',
      name: 'Diesel',
      logoAssetPath: 'assets/images/brands/diesel.svg',
      primaryColor: Color(0xFFEB292D),
    ),
    Brand(
      id: 'tommy',
      name: 'Tommy Hilfiger',
      logoAssetPath: 'assets/images/brands/tommy.svg',
      primaryColor: Color(0xFFDD0935),
    ),
    Brand(
      id: 'aldo',
      name: 'Aldo',
      logoAssetPath: 'assets/images/brands/aldo.svg',
      primaryColor: Color(0xFF000000),
    ),
    Brand(
      id: 'kikomilano',
      name: 'Kiko Milano',
      logoAssetPath: 'assets/images/brands/kikomilano.svg',
      primaryColor: Color(0xFF000000),
    ),
  ];

  static int _compareBrandNames(Brand a, Brand b) {
    // Case-insensitive, stable-ish alphabetical sort by display name.
    // Fallback to id for deterministic ordering when names match.
    final nameCmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    if (nameCmp != 0) return nameCmp;
    return a.id.toLowerCase().compareTo(b.id.toLowerCase());
  }

  static List<Brand> getAllBrands() {
    final sorted = List<Brand>.from(_brands)..sort(_compareBrandNames);
    return List.unmodifiable(sorted);
  }

  static Brand? getBrandById(String id) {
    try {
      return _brands.firstWhere((brand) => brand.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Brand> searchBrands(String query) {
    if (query.isEmpty) {
      return getAllBrands();
    }
    final lowerQuery = query.toLowerCase();
    final results = _brands
        .where((brand) => brand.name.toLowerCase().contains(lowerQuery))
        .toList();
    results.sort(_compareBrandNames);
    return results;
  }
}
