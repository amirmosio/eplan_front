import 'dart:convert';

void main() {
  B b = B();
  String bb = '{"b":true}';
  print(A.fromJson(jsonDecode(bb)));
  print(jsonEncode(b));
}

class A {
  bool b = false;

  Map<String, dynamic> toJson() => {'b': b};

  A();

  factory A.fromJson(Map<String, dynamic> json) {
    A a = A();
    a.b = json['b'];
    return a;
  }
}

class B {
  A a = A();

  B();

  factory B.fromJson(Map<String, dynamic> json) {
    B b = B();
    b.a = A.fromJson(json['a']);
    return b;
  }

  Map<String, dynamic> toJson() => {'a': a};
}
