import React, { useEffect, useState } from "react";
import {
  View,
  Text,
  Button,
  TextInput,
  ToastAndroid,
  Clipboard,
  StyleSheet,
  Linking,
} from "react-native";
import * as Notifications from "expo-notifications";
import * as Permissions from "expo-permissions";
import Constants from "expo-constants";
import { AntDesign } from "@expo/vector-icons";
import { TouchableWithoutFeedback } from "react-native-gesture-handler";

function App() {
  const [token, setToken] = useState({ data: "Loading Token..." });
  const [serverValue, onChangeserverValue] = useState("");

  useEffect(() => {
    getToken();
  }, []);

  const getToken = async () => {
    const ans = await Permissions.getAsync(Permissions.NOTIFICATIONS);
    const { status: existingStatus } = ans;
    let finalStatus = existingStatus;
    try {
      /* only ask if permissions have not already been determined, because
    iOS won't necessarily prompt the user a second time.*/
      if (existingStatus !== "granted") {
        /* Android remote notification permissions are granted during the app
      install, so this will only ask on iOS*/
        const { status } = await Permissions.askAsync(
          Permissions.NOTIFICATIONS
        );
        finalStatus = status;
      }
      /* Stop here if the user did not grant permissions*/
      /* if (finalStatus !== 'granted') {
      return;
    }*/
      let experienceId = undefined;
      // This was a little confusing for me from the docs
      // Your experience ID is basically your Expo username followed by
      // the slug for the app you need the tokens for.
      if (!Constants.manifest) experienceId = "@lud1161/Notify-Me";
      let token;
      /* Get the token that uniquely identifies this device*/
      try {
        token = await Notifications.getExpoPushTokenAsync({ experienceId });
        setToken(token);
      } catch (err) {
        console.log(err);
      }
    } catch (err) {
      console.log(err);
    }
  };

  const sendTokenToServer = async () => {
    fetch(serverValue, {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        expo_token: token.data,
      }),
    })
      .then((response) => {
        console.log(response);
        ToastAndroid.show("Token sent to server", ToastAndroid.SHORT);
      })
      .catch((error) => {
        ToastAndroid.show(response.problem, ToastAndroid.SHORT);
      });
  };

  return (
    <View
      style={{
        flex: 1,
        padding: 10,
      }}
    >
      <View
        style={{
          flex: 16,
          justifyContent: "center",
          alignItems: "center",
          alignContent: "center",
        }}
      >
        <Text style={{ marginBottom: 10 }}>
          This is your expo token : {"\n\n" + token.data}
        </Text>
        <Button
          onPress={() => {
            Clipboard.setString(token.data);
            ToastAndroid.show("Token copied to clipboard", ToastAndroid.SHORT);
          }}
          title="Click to copy token to clipboard"
        />

        <TextInput
          placeholder="Enter server address to send the expo token to"
          value={serverValue}
          onChangeText={(text) => onChangeserverValue(text)}
          style={{ margin: 20 }}
        />
        <Button onPress={sendTokenToServer} title="Send to server" />
      </View>
      <View
        style={{
          flex: 4,
          flexDirection: "row",
          justifyContent: "center",
          alignItems: "center",
          // alignContent: "center",
        }}
      >
        <TouchableWithoutFeedback
          style={{
            backgroundColor: "lightgreen",
            padding: 20,
            borderRadius: 10,
            alignItems: "center",
          }}
          onPress={() =>
            Linking.openURL(
              "https://lud1161.github.io/HackingSimplified/my-notifications/#written-tutorial"
            )
          }
        >
          <Text>Written Tutorial</Text>
        </TouchableWithoutFeedback>
        <TouchableWithoutFeedback
          style={{
            backgroundColor: "lightgreen",
            padding: 20,
            borderRadius: 10,
            alignItems: "center",
          }}
          onPress={() =>
            Linking.openURL(
              "https://lud1161.github.io/HackingSimplified/my-notifications/#video-tutorial"
            )
          }
        >
          <Text style={{ textAlign: "center" }}>Video Tutorial</Text>
        </TouchableWithoutFeedback>
      </View>
      <View style={styles.bottomView}>
        <Text
          onPress={() =>
            Linking.openURL(
              "https://www.youtube.com/channel/UCARsgS1stRbRgh99E63Q3ng"
            )
          }
        >
          Made with <Text style={{ fontWeight: "bold", color: "red" }}>❤</Text>{" "}
          in &nbsp;<Text style={{ fontWeight: "bold" }}>🇮🇳</Text>{" "}
          &nbsp;&nbsp;by&nbsp;{" "}
          <AntDesign name="youtube" color="red" size={20} />
          &nbsp;
          <Text style={{ fontWeight: "bold", color: "red" }}>Hacking</Text>
          <Text style={{ fontWeight: "bold", color: "green" }}>Simplified</Text>
        </Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  bottomView: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    fontWeight: "bold",
  },
});

export default App;
