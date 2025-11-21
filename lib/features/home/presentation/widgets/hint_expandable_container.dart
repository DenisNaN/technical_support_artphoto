import 'package:flutter/material.dart';

class HintExpandableContainer extends StatefulWidget {
  const HintExpandableContainer({super.key});

  @override
  State<HintExpandableContainer> createState() => _HintExpandableContainerState();
}

class _HintExpandableContainerState extends State<HintExpandableContainer> {
  bool active = false;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 14.0, right: 14.0, top: 14.0, bottom: 100),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          ExpansionPanelList(
            expansionCallback: (panelIndex, isExpanded) {
              active = !active;
              setState(() {});
            },
            children: [
              ExpansionPanel(
                  backgroundColor: Colors.green.shade50,
                  splashColor: Colors.yellowAccent,
                  canTapOnHeader: true,
                  isExpanded: active,
                  headerBuilder: (context, isExpanded) {
                    return Container(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Описание меток',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    );
                  },
                  body: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade500,
                                spreadRadius: 2,
                                blurRadius: 4,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: Colors.red,
                                  ),
                                  CircleAvatar(
                                    radius: 12,
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.red.shade400,
                                    child: Text('2'),
                                  )
                                ],
                              ),
                              Text(
                                'Офис',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    foregroundColor: Colors.black54,
                                    backgroundColor: Colors.yellowAccent,
                                    child: Text('2'),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  CircleAvatar(
                                    radius: 12,
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.deepOrangeAccent.shade200,
                                    child: Text('1'),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          spacing: 5,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.check,
                                  color: Colors.red,
                                ),
                                Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5, top: 4),
                                  child: Text(
                                    '- неустраненная неисправность',
                                    softWrap: true,
                                  ),
                                ))
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.red.shade400,
                                  child: Text('2'),
                                ),
                                Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5, top: 4),
                                      child: Text(
                                        '- неисправная техника',
                                        softWrap: true,
                                      ),
                                    ))
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  foregroundColor: Colors.black54,
                                  backgroundColor: Colors.yellowAccent,
                                  child: Text('2'),
                                ),
                                Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5, top: 4),
                                      child: Text(
                                        '- техника с тест-драйвом в процессе',
                                        softWrap: true,
                                      ),
                                    ))
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.deepOrangeAccent.shade200,
                                  child: Text('1'),
                                ),
                                Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5, top: 4),
                                      child: Text(
                                        '- техника с просроченным тест-драйвом',
                                        softWrap: true,
                                      ),
                                    ))
                              ],
                            ),
                            SizedBox(height: 10,)
                          ],
                        ),
                      ),
                    ],
                  )),
            ],
          )
        ]),
      ),
    );
  }
}
