import { Config, Connect, ConnectEvents } from "@vkontakte/superappkit";

Config.init({
  appId: 51516504, // Идентификатор приложения
});

export default {
  mounted() {
    const pushEvent = this.pushEvent.bind(this);
    let vkButton = Connect.buttonOneTapAuth({
      callback: function (evt) {
        const type = evt.type;
        if (!type) {
          return;
        }
        switch (type) {
          case ConnectEvents.OneTapAuthEventsSDK.LOGIN_SUCCESS:
            fetch(`/sign-in`, {
              method: "post",
              headers: {
                Accept: "application/json",
                "Content-Type": "application/json",
              },
              body: JSON.stringify(evt.payload),
            })
              .then((data) => {
                if (data.status === 200) {
                  window.location.href = "/";
                }
              });
            return;
          // Для событий PHONE_VALIDATION_NEEDED и FULL_AUTH_NEEDED нужно открыть полноценный VK ID, чтобы пользователь дорегистрировался или валидировал телефон
          case ConnectEvents.OneTapAuthEventsSDK.FULL_AUTH_NEEDED:
          case ConnectEvents.OneTapAuthEventsSDK.PHONE_VALIDATION_NEEDED:
          case ConnectEvents.ButtonOneTapAuthEventsSDK.SHOW_LOGIN:
            return Connect.redirectAuth({
              url: window.location.protocol + "//" + window.location.host,
              state: "dj29fnsadjsd82",
            });
          case ConnectEvents.ButtonOneTapAuthEventsSDK.SHOW_LOGIN_OPTIONS:
            // Параметр screen: phone позволяет сразу открыть окно ввода телефона в VK ID
            return Connect.redirectAuth({
              url: window.location.protocol + "//" + window.location.host,
              state: "dj29fnsadjsd82",
              screen: "phone",
            });
        }
        return;
      },
      options: {
        showAlternativeLogin: false, // отображает кнопку входа другим способом
        showAgreements: true, // в значении true отображает окно политик конфиденциальности в том случае, если пользователь еще не принимал политики
        displayMode: "phone_name", // отображает данных пользователя, возможные значения: default — только имя, name_phone — имя и телефон, phone_name — телефон и имя
        buttonStyles: {
          borderRadius: 12, // Радиус скругления кнопок
        },
      },
    });

    this.el.appendChild(vkButton.getFrame());
  },
};
