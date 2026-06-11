import m, { ClosureComponent, Component } from "mithril";

const component: ClosureComponent = (): Component => {
  return {
    view: (vnode) => {
      const active = { [vnode.attrs["page"]]: "active" };

      const tabs = [];
      if (window.authorizer.hasAccess("devices", 1)) {
        tabs.push(
          m(
            "li",
            { class: active["overview"] },
            m("a", { href: "#!/overview" }, "Painel"),
          ),
        );
      }

      if (window.authorizer.hasAccess("devices", 2)) {
        tabs.push(
          m(
            "li",
            { class: active["devices"] },
            m("a", { href: "#!/devices" }, "Dispositivos"),
          ),
        );
      }

      if (window.authorizer.hasAccess("faults", 2)) {
        tabs.push(
          m(
            "li",
            { class: active["faults"] },
            m("a", { href: "#!/faults" }, "Falhas"),
          ),
        );
      }

      const adminPages = [
        "presets",
        "provisions",
        "virtualParameters",
        "files",
      ];
      for (const page of adminPages) {
        if (window.authorizer.hasAccess(page, 2)) {
          tabs.push(
            m(
              "li",
              { class: active["admin"] },
              m("a", { href: "#!/admin" }, "Administração"),
            ),
          );
          break;
        }
      }

      return m("nav", { "aria-label": "Navegação principal" }, m("ul", tabs));
    },
  };
};

export default component;
