import { ClosureComponent, Component, Children } from "mithril";
import { m } from "./components.ts";
import * as store from "./store.ts";
import * as notifications from "./notifications.ts";
import * as overlay from "./overlay.ts";
import changePasswordComponent from "./change-password-component.ts";

export function init(
  args: Record<string, unknown>,
): Promise<Record<string, unknown>> {
  return Promise.resolve(args);
}

export const component: ClosureComponent = (): Component => {
  return {
    view: (vnode) => {
      if (window.username) m.route.set(vnode.attrs["continue"] || "/");

      document.title = "Entrar - GENIACS";
      return m("section.geniacs-login-page", [
        m("div.geniacs-login-hero", [
          m("div.geniacs-login-badge", "ACS"),
          m("h1", "Gestão inteligente e centralizada para sua rede."),
          m(
            "p",
            "Monitore dispositivos, acompanhe eventos e execute rotinas de suporte com uma interface mais clara, moderna e preparada para operação técnica.",
          ),
          m("div.geniacs-login-metrics", [
            m("div.geniacs-login-metric", [
              m("strong", "CWMP"),
              m("span", "Provisionamento TR-069"),
            ]),
            m("div.geniacs-login-metric", [
              m("strong", "NBI"),
              m("span", "API operacional"),
            ]),
            m("div.geniacs-login-metric", [
              m("strong", "FS"),
              m("span", "Arquivos e firmware"),
            ]),
          ]),
        ]),
        m("div.geniacs-login-card", [
          m("h2", "Acessar painel"),
          m(
            "p.geniacs-login-subtitle",
            "Entre com suas credenciais para administrar o ambiente ACS.",
          ),
          m(
            "form",
            m("p", [
              m("label", { for: "username" }, "Usuário"),
              m("input", {
                id: "username",
                name: "username",
                type: "text",
                autocomplete: "username",
                placeholder: "Digite seu usuário",
                value: vnode.state["username"],
                oncreate: (vnode2) => {
                  (vnode2.dom as HTMLInputElement).focus();
                },
                oninput: (e) => {
                  vnode.state["username"] = e.target.value;
                },
              }),
            ]),
            m("p", [
              m("label", { for: "password" }, "Senha"),
              m("input", {
                id: "password",
                name: "password",
                type: "password",
                autocomplete: "current-password",
                placeholder: "Digite sua senha",
                value: vnode.state["password"],
                oninput: (e) => {
                  vnode.state["password"] = e.target.value;
                },
              }),
            ]),
            m(
              "button.primary",
              {
                type: "submit",
                onclick: (e) => {
                  e.target.disabled = true;
                  store
                    .logIn(vnode.state["username"], vnode.state["password"])
                    .then(() => {
                      location.reload();
                    })
                    .catch((err) => {
                      notifications.push("error", err.response || err.message);
                      e.target.disabled = false;
                    });
                  return false;
                },
              },
              "Entrar",
            ),
          ),
          m(
            "a.change-password-link",
            {
              onclick: () => {
                const cb = (): Children => {
                  const attrs = {
                    onPasswordChange: () => {
                      overlay.close(cb);
                      m.redraw();
                    },
                  };
                  return m(changePasswordComponent, attrs);
                };
                overlay.open(cb);
              },
            },
            "Alterar senha",
          ),
        ]),
      ]);
    },
  };
};
