#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "qiosnativetextfield.h"

int main(int argc, char* argv[]) {
  QGuiApplication app(argc, argv);

  qmlRegisterType<QiOSNativeTextField>("QiOSNative", 1, 0, "NativeTextField");

  QQmlApplicationEngine engine;
  engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

  return app.exec();
}
