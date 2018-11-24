void setup(){
  pinMode(13,OUTPUT); //13番ピンを出力に設定

  Serial.begin(9600);//シリアル通信のレートを9600に設定
}

void loop(){

  int inputchar;      //入力状態の読み取りに使う

  inputchar = Serial.read();  //シリアル通信で送信された値を読み取る

  if(inputchar!=-1){
    switch(inputchar){
      case 's':
        digitalWrite(13,HIGH);
        break;

      case 'q':
        digitalWrite(13,LOW);
        break;
    }
  }
  else{
  }
}
