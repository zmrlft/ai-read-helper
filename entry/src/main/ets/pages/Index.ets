@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Column(){
      Row(){
        Text("欢迎来到文字识别系统")
          .fontSize(25)
          .fontColor("#fff")
          .width(300)
          .height(80)
          .border({
            width:1,
            radius:5,
            color:"#FFF"
          })
          .margin(20)
          .textAlign(TextAlign.Center)
      }
      Column(){
        Image($r("app.media.bg"))
          .width(400)
          .height(400)
          .margin(30)
      }
      .alignItems(HorizontalAlign.Center)
      Blank()
      Row({space:20}){
        Button("开始拍照")
          .backgroundColor("#cbffffff")
          .fontSize(20)
          .fontColor("#000")
          .height(80)
          .width(150)
          .borderRadius(10)
          .opacity(0.8)
        Button("相册选择")
          .backgroundColor("#cbffffff")
          .fontSize(20)
          .fontColor("#000")
          .height(80)
          .width(150)
          .borderRadius(10)
          .opacity(0.8)
      }


    }
    .width('100%')
    .height('100%')
    .backgroundColor("#ff6bb5e7")
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}