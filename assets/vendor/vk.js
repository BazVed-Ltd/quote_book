import { Config, Connect, ConnectEvents } from "@vkontakte/superappkit";

const SIGN_IN_PATH = "/sign-in";
const BASE_URL = `${window.location.protocol}//${window.location.host}`;
const REDIRECT_AUTH_URL = `${BASE_URL}${SIGN_IN_PATH}`;

const VK_ONE_TAP_OPTIONS = {
  showAlternativeLogin: false, // отображает кнопку входа другим способом
  showAgreements: true, // в значении true отображает окно политик конфиденциальности в том случае, если пользователь еще не принимал политики
  displayMode: "phone_name", // отображает данных пользователя, возможные значения: default — только имя, name_phone — имя и телефон, phone_name — телефон и имя
  buttonStyles: {
    borderRadius: 12, // Радиус скругления кнопок
  },
};

function try_login_with_payload(errorPusher, returnTo) {
  const params = new Proxy(new URLSearchParams(window.location.search), {
    get: (searchParams, prop) => searchParams.get(prop),
  });

  if (params.payload != undefined) {
    return login(JSON.parse(params.payload), errorPusher, returnTo);
  }
  return new Promise(() => undefined);
}

async function login(payload, errorPusher, returnTo) {
  params = new URLSearchParams({
    payload: JSON.stringify(payload),
  });
  const response = await fetch(`${SIGN_IN_PATH}?${params}`, {
    method: "post",
  });
  if (response.status === 200) {
    window.location.href = returnTo;
  } else {
    const text = await response.text();
    errorPusher(text);
  }
}

function createErrorPusher(pushEvent) {
  return (error) => pushEvent("error", error);
}

export default {
  mounted() {
    const returnTo = this.el.dataset.returnTo;

    Config.init({
      appId: 51516504, // Идентификатор приложения
    });

    const errorPusher = createErrorPusher(this.pushEvent.bind(this));

    try_login_with_payload(errorPusher, returnTo);

    let vkButton = Connect.buttonOneTapAuth({
      callback: function (evt) {
        if (!evt.type) return;
        switch (evt.type) {
          case ConnectEvents.OneTapAuthEventsSDK.LOGIN_SUCCESS:
            login(evt.payload, errorPusher, returnTo);
            return;
          // Для событий PHONE_VALIDATION_NEEDED и FULL_AUTH_NEEDED нужно открыть полноценный VK ID, чтобы пользователь дорегистрировался или валидировал телефон
          case ConnectEvents.OneTapAuthEventsSDK.FULL_AUTH_NEEDED:
          case ConnectEvents.OneTapAuthEventsSDK.PHONE_VALIDATION_NEEDED:
          case ConnectEvents.ButtonOneTapAuthEventsSDK.SHOW_LOGIN:
            return Connect.redirectAuth({
              url: REDIRECT_AUTH_URL,
            });
          case ConnectEvents.ButtonOneTapAuthEventsSDK.SHOW_LOGIN_OPTIONS:
            // Параметр screen: phone позволяет сразу открыть окно ввода телефона в VK ID
            return Connect.redirectAuth({
              url: REDIRECT_AUTH_URL,
              screen: "phone",
            });
        }
        return;
      },
      options: VK_ONE_TAP_OPTIONS,
    });

    this.el.appendChild(vkButton.getFrame());
  },
};
