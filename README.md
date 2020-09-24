# alphabetNumRecognize

目前主流有两种库:
1 Tesseract-OCR-iOS库，功能强,耗内存,不能识别手写,
2 SwiftOCR库，适用于快速识别单行文本，速度比TesseractOCRiOS快得多。集成很方便，但识别手机号的准确性问题很大。换字体识别率就低
选了第二种

安装是用了pod安装方式

NumRecoDemo里面有三种不同方法(在StoryBoard里面切换entry来分别跑以下三种):
SimpleTestViewController是最简单,测试一张内置的测试图片
CamViewController是用摄像头拍照方式识别(原封不动用了SwiftOCR的example的代码,控制台大量信息都是由其产生)
ViewController是参照人脸识别的方式用摄像头实时测,但识别文字错误,还没继续下去
