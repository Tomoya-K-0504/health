// アナログ入力の値に応じてLEDの点滅レートが変化

const int LED = 13;

int val = 0; // 入力ピンの状態

void setup() {
  pinMode(LED, OUTPUT); // LED が接続されたピンを出力に設定  
}

void loop() {
  val = digitalRead(); // 入力を読み取り、valに格納

  if (val == HIGH) {
    digitalWrite(LED, HIGH); // LEDをオン
  } else {
    digitalWrite(LED, LOW); // LEDをオフ
  }
}
