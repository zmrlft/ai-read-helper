import { picker } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { promptAction } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ShowResult } from './ShowResult';

// 定义接口
interface ImageUrl {
  url: string;
}

interface ContentItem {
  type: string;
  image_url?: ImageUrl;
  text?: string;
}

interface Message {
  role: string;
  content: ContentItem[];
}

interface ApiRequestBody {
  model: string;
  messages: Message[];
  stream: boolean;
}

interface PhotoSelectResult {
  photoUris: Array<string>;
}

interface ChoiceItem {
  message?: MessageContent;
}

interface MessageContent {
  content?: string;
}

interface ApiResponse {
  choices?: Array<ChoiceItem>;
}

interface HttpRequestOptions {
  method: http.RequestMethod;
  header: Record<string, string>;
  extraData: string;
  connectTimeout: number;
  readTimeout: number;
}

export class Constants {
  static readonly ACTION_PICKER_CAMERA: string = "ohos.want.action.imageCapture";
  static readonly KEY_RESULT_PICKER_CAMERA: string = "resourceUri";
  static readonly API_URL: string = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions";
  static readonly API_KEY: string = "";
}

// Base64编码函数
function base64Encode(buffer: ArrayBuffer): string {
  try {
    const bytes = new Uint8Array(buffer);
    const base64Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    let result = '';

    for (let i = 0; i < bytes.length; i += 3) {
      const b1 = bytes[i];
      const b2 = bytes[i + 1] || 0;
      const b3 = bytes[i + 2] || 0;

      const enc1 = b1 >> 2;
      const enc2 = ((b1 & 3) << 4) | (b2 >> 4);
      const enc3 = ((b2 & 15) << 2) | (b3 >> 6);
      const enc4 = b3 & 63;

      result += base64Chars.charAt(enc1);
      result += base64Chars.charAt(enc2);
      result += (i + 1 < bytes.length) ? base64Chars.charAt(enc3) : '=';
      result += (i + 2 < bytes.length) ? base64Chars.charAt(enc4) : '=';
    }

    return result;
  } catch (error) {
    console.error('Base64编码失败');
    return "";
  }
}

// 图片转Base64 - 修复版
async function imageToBase64(uri: string): Promise<string> {
  let file: fileIo.File | null = null;

  try {
    console.log('处理URI:', uri);

    // 鸿蒙返回的URI可以直接使用，不需要去掉file://前缀
    file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
    const stat = fileIo.statSync(file.fd);

    console.log('文件大小:', stat.size);

    if (stat.size === 0) {
      console.error('文件大小为0');
      return "";
    }

    // 限制文件大小
    if (stat.size > 10 * 1024 * 1024) {
      promptAction.showToast({ message: '图片太大，请选择5MB以内的图片', duration: 2000 });
      return "";
    }

    const arrayBuffer = new ArrayBuffer(stat.size);
    const bytesRead = fileIo.readSync(file.fd, arrayBuffer);

    console.log('成功读取字节:', bytesRead);

    if (bytesRead > 0) {
      const base64 = base64Encode(arrayBuffer);
      console.log('Base64编码成功');
      return base64;
    }

    return "";
  } catch (error) {
    const err = error as BusinessError;
    console.error('文件访问失败，错误码:', err.code);

    // 尝试去掉file://前缀
    try {
      if (uri.startsWith('file://')) {
        const filePath = uri.substring(7);
        console.log('尝试新路径:', filePath);

        const file2 = fileIo.openSync(filePath, fileIo.OpenMode.READ_ONLY);
        const stat = fileIo.statSync(file2.fd);

        const arrayBuffer = new ArrayBuffer(stat.size);
        const bytesRead = fileIo.readSync(file2.fd, arrayBuffer);

        if (bytesRead > 0) {
          return base64Encode(arrayBuffer);
        }
        fileIo.closeSync(file2);
      }
    } catch (secondError) {
      console.error('第二次尝试也失败');
    }

    return "";
  } finally {
    if (file) {
      fileIo.closeSync(file);
    }
  }
}

// 发送API请求
async function sendImageToAPI(base64Image: string): Promise<string> {
  try {
    const requestBody: ApiRequestBody = {
      model: "qwen-omni-turbo",
      messages: [
        {
          role: "user",
          content: [
            {
              type: "image_url",
              image_url: {
                url: `data:image/jpeg;base64,${base64Image}`
              }
            },
            {
              type: "text",
              text: "请分析这张图片"
            }
          ]
        }
      ],
      stream: false
    };

    const requestOptions: HttpRequestOptions = {
      method: http.RequestMethod.POST,
      header: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${Constants.API_KEY}`
      },
      extraData: JSON.stringify(requestBody),
      connectTimeout: 60000,
      readTimeout: 60000
    };

    const httpRequest = http.createHttp();
    const response = await httpRequest.request(Constants.API_URL, requestOptions);

    if (response.responseCode === http.ResponseCode.OK) {
      const result = JSON.parse(response.result.toString()) as ApiResponse;
      return result.choices?.[0]?.message?.content || '无返回内容';
    }

    return `请求失败: ${response.responseCode}`;
  } catch (error) {
    const err = error as BusinessError;
    return 'API请求失败: ' + JSON.stringify(err);
  }
}

export async function cameraCapture(context: common.UIAbilityContext): Promise<string> {
  try {
    const result: common.AbilityResult = await context.startAbilityForResult({
      action: Constants.ACTION_PICKER_CAMERA,
      parameters: {
        'supportMultiMode': false,
        'callBundleName': context.abilityInfo.bundleName
      }
    });

    if (result.resultCode === 0 && result.want?.parameters) {
      return result.want.parameters[Constants.KEY_RESULT_PICKER_CAMERA] as string;
    }
    return "";
  } catch (error) {
    return "";
  }
}

const photoSelectOptions = new picker.PhotoSelectOptions();
photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
photoSelectOptions.maxSelectNumber = 1;

@Entry
@Component
struct Index {
  @State selectedImage: string = '';
  @State base64Content: string = '';
  @State errorMessage: string = '';
  @State isLoading: boolean = false;
  @State apiResponse: string = '';
  @State showDialog:boolean = false;
  @Builder
  resultBuilder() {
    // 大坑：最外层必须得是容器组件
    Column(){
      ShowResult({result:this.apiResponse})
    }
  }
  // 清理状态
  cleanup(): void {
    this.selectedImage = '';
    this.base64Content = '';
    this.apiResponse = '';
    this.errorMessage = '';
    this.isLoading = false;
  }

  // 拍照
  async photographUpload(): Promise<void> {
    this.cleanup();
    try {
      const context = getContext() as common.UIAbilityContext;
      const image: string = await cameraCapture(context);

      if (image) {
        this.selectedImage = image;
        this.base64Content = await imageToBase64(image);

        if (!this.base64Content) {
          this.errorMessage = '图片处理失败，请重试';
        }
      } else {
        this.errorMessage = '拍照失败';
      }
    } catch (error) {
      this.errorMessage = '拍照出错';
    }
  }

  // 相册选择
  async selectFromGallery(): Promise<void> {
    this.cleanup();
    try {
      const context = getContext() as common.UIAbilityContext;
      const photoPicker = new picker.PhotoViewPicker();
      const result = await photoPicker.select(photoSelectOptions);

      if (result && (result as PhotoSelectResult).photoUris && (result as PhotoSelectResult).photoUris.length > 0) {
        this.selectedImage = (result as PhotoSelectResult).photoUris[0];
        this.base64Content = await imageToBase64(this.selectedImage);

        if (!this.base64Content) {
          this.errorMessage = '图片处理失败，请重试';
        }
      } else {
        this.errorMessage = '未选择图片';
      }
    } catch (error) {
      this.errorMessage = '选择图片出错';
    }
  }

  // 发送API
  async sendToAPI(): Promise<void> {
    if (!this.base64Content) {
      this.errorMessage = '请先选择图片';
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      this.apiResponse = await sendImageToAPI(this.base64Content);
    } catch (error) {
      this.errorMessage = 'API请求失败';
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      Text('欢迎来到文字识别系统')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 30 })
      if (!this.selectedImage){
        Image($r('app.media.bg'))
          .width(400)
          .height(400)
          .margin(30)
      }
      if (this.selectedImage) {
        Image(this.selectedImage)
          .width(200)
          .height(200)
          .margin({ bottom: 20 })
      }

      if (this.base64Content && !this.isLoading) {
        Button('分析图片')
          .onClick(() =>{
            this.sendToAPI()
            this.showDialog = true;
          })
          .margin({ bottom: 20 })
          .bindSheet($$this.showDialog, this.resultBuilder(), {
            showClose: false,
            height: '60%'
          })
          .backgroundColor("#cbffffff")
          .height(80)
          .width(150)
          .fontColor("#000")
          .fontSize(20)
      }

      if (this.isLoading) {
        Text('处理中...')
          .margin({ bottom: 20 })
      }

      if (this.errorMessage) {
        Text(this.errorMessage)
          .fontColor(Color.Red)
          .margin({ bottom: 10 })
      }
      Blank()

      Row({ space: 20 }) {
        Button("开始拍照")
          .backgroundColor("#cbffffff")
          .fontSize(20)
          .fontColor("#000")
          .height(80)
          .width(150)
          .borderRadius(10)
          .opacity(0.8)
          .onClick(() => this.photographUpload())

        Button("相册选择")
          .backgroundColor("#cbffffff")
          .fontSize(20)
          .fontColor("#000")
          .height(80)
          .width(150)
          .borderRadius(10)
          .opacity(0.8)
          .onClick(() => this.selectFromGallery())
      }
      .margin({ bottom: 30 })




    }
    .padding(20)
    .width('100%')
    .height('100%')
    .backgroundColor("#ff6bb5e7")
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}