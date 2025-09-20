@Component
struct ShowResult {
  @Prop result: string

  build() {
    Column() {

      // 添加Scroll组件使内容可滚动
      Scroll() {
        Text(this.result)
          .padding(20)
          .fontSize(30)
      }
      .width('100%')
      .height('100%') // 可以根据需要调整高度
    }
    .width('100%')
    .height('100%')
    .backgroundColor("#ff41d1ea")
  }
}

export { ShowResult }