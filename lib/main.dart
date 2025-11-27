import 'package:flutter/material.dart';
import 'package:pop_demo/pop_back_handler.dart' show PopBackHandler;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(title: '返回监听示例', debugShowCheckedModeBanner: false, home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("HomePage")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const BackListenerPage()));
              },
              child: const Text("测试 WillPopScope"),
            ),
            // 新增 PopScope 测试按钮
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PopScopeTestOldPage()));
              },
              child: const Text("测试 PopScope 旧版"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PopScopeTestPage()));
              },
              child: const Text("测试 PopScope 最新版"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PopScopeTestCustomPage()));
              },
              child: const Text("测试 PopScope 自定义版"),
            ),
          ],
        ),
      ),
    );
  }
}

// 原 WillPopScope 测试页面（保留）
class BackListenerPage extends StatefulWidget {
  const BackListenerPage({super.key});

  @override
  State<BackListenerPage> createState() => _BackListenerPageState();
}

class _BackListenerPageState extends State<BackListenerPage> {
  Future<bool> _showExitConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("提示"),
                content: const Text("确定要退出当前页面吗？"),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("取消")),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("确定")),
                ],
              ),
        ) ??
        false;
  }

  // 统一的返回处理逻辑
  Future<void> _handlePopRequest() async {
    bool isExit = await _showExitConfirmDialog();
    if (isExit && mounted) {
      Navigator.pop(context, "pop_result");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _showExitConfirmDialog,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("WillPopScope 示例"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await _handlePopRequest();
            },
          ),
        ),
        body: const Center(child: Text("尝试系统返回或点击左上角返回")),
      ),
    );
  }
}

// 新增 PopScope 测试页面
class PopScopeTestOldPage extends StatefulWidget {
  const PopScopeTestOldPage({super.key});

  @override
  State<PopScopeTestOldPage> createState() => _PopScopeTestOldPageState();
}

class _PopScopeTestOldPageState extends State<PopScopeTestOldPage> {
  // 弹窗逻辑复用
  Future<bool> _showExitConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("提示"),
                content: const Text("确定要退出当前页面吗？（PopScope 测试）"),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("取消")),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("确定")),
                ],
              ),
        ) ??
        false;
  }

  // 统一的返回处理逻辑
  Future<void> _handlePopRequest() async {
    bool isExit = await _showExitConfirmDialog();
    if (isExit && mounted) {
      Navigator.pop(context, "pop_result");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // canPop: false 表示阻止默认的返回行为（必须手动处理）
      canPop: false,
      // onPopInvoked：当返回事件被触发时调用（系统返回/手动返回都能触发）
      onPopInvoked: (bool didPop) async {
        // didPop 表示是否已经由框架完成了 pop 操作（这里因 canPop=false，didPop 始终为 false）
        if (!didPop) {
          await _handlePopRequest();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("PopScope 示例"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              // 自定义返回按钮也触发相同逻辑
              bool isExit = await _showExitConfirmDialog();
              if (isExit) Navigator.pop(context);
            },
          ),
        ),
        body: const Center(child: Text("尝试系统返回或点击左上角返回（PopScope 测试）")),
      ),
    );
  }
}

// 适配最新版 PopScope（使用 onPopInvokedWithResult）
class PopScopeTestPage extends StatefulWidget {
  const PopScopeTestPage({super.key});

  @override
  State<PopScopeTestPage> createState() => _PopScopeTestPageState();
}

class _PopScopeTestPageState extends State<PopScopeTestPage> {
  // 弹窗逻辑复用
  Future<bool> _showExitConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("提示"),
                content: const Text("确定要退出当前页面吗？（PopScope 最新版）"),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("取消")),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("确定")),
                ],
              ),
        ) ??
        false;
  }

  // 统一的返回处理逻辑
  Future<void> _handlePopRequest() async {
    bool isExit = await _showExitConfirmDialog();
    if (isExit && mounted) {
      Navigator.pop(context, "pop_result");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // canPop: false 阻止框架默认返回行为
      canPop: false,
      // 新回调：onPopInvokedWithResult（替代废弃的 onPopInvoked）
      // 参数1：didPop - 框架是否已自动完成pop（canPop=false时始终为false）
      // 参数2：result - 页面返回时携带的结果（这里暂时用不到）
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          await _handlePopRequest();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("PopScope 最新版示例"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              // 自定义返回按钮逻辑不变
              bool isExit = await _showExitConfirmDialog();
              if (isExit && mounted) Navigator.pop(context);
            },
          ),
        ),
        body: const Center(child: Text("尝试系统返回或点击左上角返回\n（onPopInvokedWithResult）")),
      ),
    );
  }
}

// 适配最新版 PopScope（使用 onPopInvokedWithResult）
// 解决 iOS 侧滑返回在 canPop: false 时不触发回调的问题
class PopScopeTestCustomPage extends StatefulWidget {
  const PopScopeTestCustomPage({super.key});

  @override
  State<PopScopeTestCustomPage> createState() => _PopScopeTestCustomPageState();
}

class _PopScopeTestCustomPageState extends State<PopScopeTestCustomPage> {
  // 弹窗逻辑复用
  Future<bool> _showExitConfirmDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("提示"),
                content: const Text("确定要退出当前页面吗？（PopScope 最新版）"),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("取消")),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("确定")),
                ],
              ),
        ) ??
        false;
  }

  // 统一的返回处理逻辑
  Future<void> _handlePopRequest() async {
    bool isExit = await _showExitConfirmDialog();
    if (isExit && mounted) {
      Navigator.pop(context, "pop_result");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopBackHandler(
      // 统一处理所有返回事件（Android 返回键 + iOS 侧滑）
      onPopRequested: _handlePopRequest,
      // enableInterceptBack: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("PopScope 自定义版示例"),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _handlePopRequest),
        ),
        body: const Center(child: Text("尝试系统返回或点击左上角返回\n\n已统一封装 PopScope + iOS 侧滑检测")),
      ),
    );
  }
}
