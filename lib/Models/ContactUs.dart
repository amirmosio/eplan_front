class ContactUs {
  String phone = "";
  String instagram = "";
  String telegram = "";
  String whatsapp = "";
  String appDescription = "";

  ContactUs();

  factory ContactUs.fromJson(Map<String, dynamic> json) {
    ContactUs c = ContactUs();
    c.phone = json['phone'];
    c.instagram = json['instagram'];
    c.telegram = json['telegram'];
    c.whatsapp = json['whatsapp'];
    c.appDescription = json['appDescription'];
    return c;
  }
}
