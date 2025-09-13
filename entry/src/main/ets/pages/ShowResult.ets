@Component
struct ShowResult {
  @Prop result: string

  build() {
    Column() {
      Row() {
        Image($r('app.media.startIcon'))
          .width(20)
          .height(20)
          .padding({
            right: 20
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)

      // 添加Scroll组件使内容可滚动
      Scroll() {
        Text(this.result)
          .padding(20)
      }
      .width('100%')
      .height('100%') // 可以根据需要调整高度
    }
    .width('100%')
    .height('100%')
  }
}

export { ShowResult }