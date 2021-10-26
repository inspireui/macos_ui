import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:provider/provider.dart';

import '../theme.dart';

class ButtonsPage extends StatefulWidget {
  const ButtonsPage({Key? key}) : super(key: key);

  @override
  _ButtonsPageState createState() => _ButtonsPageState();
}

class _ButtonsPageState extends State<ButtonsPage> {
  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
      titleBar: TitleBar(
        title: const Text('macOS UI Widget Gallery'),
        actions: [
          MacosIconButton(
            backgroundColor: MacosColors.transparent,
            icon: const MacosIcon(
              CupertinoIcons.sidebar_left,
              color: MacosColors.systemGrayColor,
            ),
            onPressed: () {
              MacosWindowScope.of(context).toggleSidebar();
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      children: [
        ResizablePane(
          minWidth: 180,
          startWidth: 200,
          windowBreakpoint: 700,
          resizableSide: ResizableSide.right,
          builder: (_, __) {
            return const Center(
              child: Text('Resizable Pane'),
            );
          },
        ),
        ContentArea(builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text('MacosBackButton'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MacosBackButton(
                      onPressed: () => print('click'),
                      fillColor: Colors.transparent,
                    ),
                    const SizedBox(width: 16.0),
                    MacosBackButton(
                      onPressed: () => print('click'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('MacosIconButton'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MacosIconButton(
                      icon: const MacosIcon(
                        CupertinoIcons.star_fill,
                        color: Colors.white,
                      ),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(7),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    const MacosIconButton(
                      icon: MacosIcon(
                        CupertinoIcons.plus_app,
                        color: Colors.white,
                      ),
                      shape: BoxShape.circle,
                      //onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                    MacosIconButton(
                      icon: const MacosIcon(
                        CupertinoIcons.minus_square,
                        color: Colors.white,
                      ),
                      backgroundColor: Colors.transparent,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                PushButton(
                  buttonSize: ButtonSize.large,
                  child: const Text('large PushButton'),
                  onPressed: () {
                    MacosWindowScope.of(context).toggleSidebar();
                  },
                ),
                const SizedBox(height: 20),
                PushButton(
                  buttonSize: ButtonSize.small,
                  child: const Text('small PushButton'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) {
                          return MacosScaffold(
                            titleBar: const TitleBar(
                              centerTitle: false,
                              title: Text('New page'),
                            ),
                            children: [
                              ContentArea(
                                builder: (context, scrollController) {
                                  return Center(
                                    child: PushButton(
                                      buttonSize: ButtonSize.large,
                                      child: const Text('Go Back'),
                                      onPressed: () {
                                        Navigator.maybePop(context);
                                      },
                                    ),
                                  );
                                },
                              ),
                              ResizablePane(
                                minWidth: 180,
                                startWidth: 200,
                                windowBreakpoint: 700,
                                resizableSide: ResizableSide.left,
                                builder: (_, __) {
                                  return const Center(
                                    child: Text('Resizable Pane'),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                PushButton(
                  buttonSize: ButtonSize.large,
                  isSecondary: true,
                  child: const Text('secondary PushButton'),
                  onPressed: () {
                    MacosWindowScope.of(context).toggleSidebar();
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('System Theme'),
                    const SizedBox(width: 8),
                    MacosRadioButton<ThemeMode>(
                      groupValue: context.watch<AppTheme>().mode,
                      value: ThemeMode.system,
                      onChanged: (value) {
                        context.read<AppTheme>().mode = value!;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Light Theme'),
                    const SizedBox(width: 24),
                    MacosRadioButton<ThemeMode>(
                      groupValue: context.watch<AppTheme>().mode,
                      value: ThemeMode.light,
                      onChanged: (value) {
                        context.read<AppTheme>().mode = value!;
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Dark Theme'),
                    const SizedBox(width: 26),
                    MacosRadioButton<ThemeMode>(
                      groupValue: context.watch<AppTheme>().mode,
                      value: ThemeMode.dark,
                      onChanged: (value) {
                        context.read<AppTheme>().mode = value!;
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        ResizablePane(
          minWidth: 180,
          startWidth: 200,
          windowBreakpoint: 800,
          resizableSide: ResizableSide.left,
          builder: (_, __) {
            return const Center(
              child: Text('Resizable Pane'),
            );
          },
        ),
      ],
    );
  }
}
