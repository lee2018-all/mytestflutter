class RuteBean {
  String? name;
  String? path;
  bool? hidden;
  String? redirect;
  String? component;
  bool? alwaysShow;
  MetaDTO? meta;
  List<ChildrenDTO>? children;

  RuteBean({
    this.name,
    this.path,
    this.hidden,
    this.redirect,
    this.component,
    this.alwaysShow,
    this.meta,
    this.children,
  });

  factory RuteBean.fromJson(Map<String, dynamic> json) {
    return RuteBean(
      name: json['name'],
      path: json['path'],
      hidden: json['hidden'],
      redirect: json['redirect'],
      component: json['component'],
      alwaysShow: json['alwaysShow'],
      meta: json['meta'] != null ? MetaDTO.fromJson(json['meta']) : null,
      children: json['children'] != null
          ? (json['children'] as List).map((e) => ChildrenDTO.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'hidden': hidden,
      'redirect': redirect,
      'component': component,
      'alwaysShow': alwaysShow,
      'meta': meta?.toJson(),
      'children': children?.map((e) => e.toJson()).toList(),
    };
  }
}

class MetaDTO {
  String? title;
  String? icon;
  bool? noCache;
  dynamic link; // Object 类型，可以是 String 或其他

  MetaDTO({
    this.title,
    this.icon,
    this.noCache,
    this.link,
  });

  factory MetaDTO.fromJson(Map<String, dynamic> json) {
    return MetaDTO(
      title: json['title'],
      icon: json['icon'],
      noCache: json['noCache'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'icon': icon,
      'noCache': noCache,
      'link': link,
    };
  }
}

class ChildrenDTO {
  String? name;
  String? path;
  bool? hidden;
  String? component;
  MetaDTOX? meta;
  String? query;
  List<ChildrenDTO>? children; // 支持嵌套子路由

  ChildrenDTO({
    this.name,
    this.path,
    this.hidden,
    this.component,
    this.meta,
    this.query,
    this.children,
  });

  factory ChildrenDTO.fromJson(Map<String, dynamic> json) {
    return ChildrenDTO(
      name: json['name'],
      path: json['path'],
      hidden: json['hidden'],
      component: json['component'],
      meta: json['meta'] != null ? MetaDTOX.fromJson(json['meta']) : null,
      query: json['query'],
      children: json['children'] != null
          ? (json['children'] as List).map((e) => ChildrenDTO.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'hidden': hidden,
      'component': component,
      'meta': meta?.toJson(),
      'query': query,
      'children': children?.map((e) => e.toJson()).toList(),
    };
  }
}

class MetaDTOX {
  String? title;
  String? icon;
  bool? noCache;
  dynamic link; // Object 类型，可以是 String 或其他

  MetaDTOX({
    this.title,
    this.icon,
    this.noCache,
    this.link,
  });

  factory MetaDTOX.fromJson(Map<String, dynamic> json) {
    return MetaDTOX(
      title: json['title'],
      icon: json['icon'],
      noCache: json['noCache'],
      link: json['link'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'icon': icon,
      'noCache': noCache,
      'link': link,
    };
  }
}