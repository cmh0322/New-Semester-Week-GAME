const int buttonPins[] = {2, 3, 4, 5};
const char keys[] = {'A', 'B', 'C', 'D'};
bool lastStates[] = {HIGH, HIGH, HIGH, HIGH};

void setup() {
  Serial.begin(115200);
  for (int i = 0; i < 4; i++) {
    pinMode(buttonPins[i], INPUT_PULLUP);
  }
}

void loop() {
  for (int i = 0; i < 4; i++) {
    bool currentState = digitalRead(buttonPins[i]);

    if (lastStates[i] == HIGH && currentState == LOW) {
      Serial.print(keys[i]); 
    }
    lastStates[i] = currentState;
  }
  delay(5);
}