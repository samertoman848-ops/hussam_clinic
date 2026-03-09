import 'package:flutter/material.dart';
import '../../global_var/globals.dart';
import '../../main.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import '../../model/accounting/AccoutingTreeModel.dart';
import '../../pages/accounting/invoices/SalesInvoices.dart';

const showSnackBar = false;
const expandChildrenOnReady = true;

class SelectTrees extends StatefulWidget {
  const SelectTrees({super.key});
  @override
  State<StatefulWidget> createState() => _SelectTreesState();
}

int foundIndex = 0;
TextStyle textStyle = const TextStyle(
  fontWeight: FontWeight.bold,
  color: Colors.green,
  fontSize: 20,
);

class _SelectTreesState extends State<SelectTrees> {
  final GlobalKey<SliverTreeViewState> _indexedTreeKey =
      GlobalKey<SliverTreeViewState>();
  final AutoScrollController scrollController = AutoScrollController();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _buildDialogContent(context),
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    buildTree();
    final mq = MediaQuery.of(context).size;
    final dialogHeight = mq.height * 0.8;
    final dialogWidth = mq.width * 0.6;
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Container(
          height: dialogHeight,
          width: dialogWidth,
          // Bottom rectangular box
          margin: const EdgeInsets.only(
              top: 10), // to push the box half way below circle
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.only(
              top: 20, left: 10, right: 12), // spacing inside the box
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'اختار القائمة المطلوبة',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Expanded(
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    const SliverToBoxAdapter(
                      child: Padding(
                          padding: EdgeInsets.only(top: 12.0),
                          child: SizedBox(
                            height: 5,
                          )),
                    ),

                    ///Indexed [SliverTreeView] example
                    SliverTreeView.indexed(
                      key: _indexedTreeKey,
                      tree: indexedTrrre,
                      scrollController: scrollController,
                      expansionIndicatorBuilder: (context, node) =>
                          //ChevronIndicator.upDown(tree: tree)
                          PlusMinusIndicator(
                        alignment: Alignment.centerLeft,
                        tree: node,
                        color: Colors.white,
                        padding: const EdgeInsets.all(8),
                      ),
                      indentation: const Indentation(
                        style: IndentStyle.squareJoint,
                        width: 20,
                        thickness: 2,
                      ),
                      expansionBehavior: ExpansionBehavior.scrollToLastChild,
                      onItemTap:
                          (IndexedTreeNode<AccoutingTreeModel> IndexNode) {
                        if (IndexNode.isLeaf) {
                          setState(() {
                            VMSalesInvoice.AccountingTo_select_id =
                                IndexNode.key;
                            VMSalesInvoice.AccountingTo_select_name =
                                IndexNode.data!.name;
                          });
                          Navigator.of(context).pop();
                        }
                      },
                      builder: (context, node) => Card(
                        color: colorMapper[
                            node.level.clamp(0, colorMapper.length - 1)]!,
                        child:
                            //Container
                            ListTile(
                          title: Text("${node.key}-${node.data?.name}"),
                          // subtitle:  Text('${node.data?.name} ${node.data?.branch_no}'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  final indexedTrrre = IndexedTreeNode<AccoutingTreeModel>.root(
      data: AccoutingTreeModel.Valueed(1, "الشجرة المحاسبية", '0', '0', '0'));
  void buildTree() {
    List<AccoutingTreeModel> allAccountingBrach1 = [];
    List<AccoutingTreeModel> allAccountingBrach2 = [];
    List<AccoutingTreeModel> allAccountingBrach3 = [];
    List<AccoutingTreeModel> allAccountingBrach4 = [];
    List<AccoutingTreeModel> allAccountingBrach5 = [];
    List<IndexedTreeNode> IndexNode1 = [];
    List<IndexedTreeNode> IndexNode2 = [];
    List<IndexedTreeNode> IndexNode3 = [];
    List<IndexedTreeNode> IndexNode4 = [];
    List<IndexedTreeNode> IndexNode5 = [];
    indexedTrrre.clear();
    for (var root in allAccountingTree) {
      if (int.parse(root.branch_no) < 10) {
        indexedTrrre.add(IndexedTreeNode<AccoutingTreeModel>(
            key: root.branch_no, data: root));
        allAccountingBrach1.clear();
        allAccountingBrach1.addAll(allAccountingTree.where((Node1) =>
            int.parse(Node1.father_no) == int.parse(root.branch_no) &&
            Node1.father_no.compareTo(Node1.branch_no) != 0));
        if (allAccountingBrach1.isNotEmpty) {
          //add  root without node
          ///Start for loop node 1
          for (var Node1 in allAccountingBrach1) {
            IndexNode1.clear();
            IndexNode1.add(IndexedTreeNode<AccoutingTreeModel>(
                key: Node1.branch_no, data: Node1));
            indexedTrrre.elementAt(root.branch_no).addAll(IndexNode1);
            IndexNode2.clear();
            allAccountingBrach2.clear();
            allAccountingBrach2.addAll(allAccountingTree.where((Node2) =>
                Node2.father_no.compareTo(Node1.branch_no) == 0 &&
                Node2.father_no.compareTo(Node2.branch_no) != 0));

            ///End for loop node 1
            if (allAccountingBrach2.isNotEmpty) {
              for (var Node2 in allAccountingBrach2) {
                IndexNode2.clear();
                IndexNode2.add(IndexedTreeNode<AccoutingTreeModel>(
                    key: Node2.branch_no, data: Node2));
                indexedTrrre
                    .elementAt("${root.branch_no}.${Node1.branch_no}")
                    .addAll(IndexNode2);
                IndexNode3.clear();
                allAccountingBrach3.clear();
                allAccountingBrach3.addAll(allAccountingTree.where((Node3) =>
                    Node3.father_no.compareTo(Node2.branch_no) == 0 &&
                    Node3.father_no.compareTo(Node3.branch_no) != 0));
                if (allAccountingBrach3.isNotEmpty) {
                  for (var Node3 in allAccountingBrach3) {
                    IndexNode3.clear();
                    IndexNode3.add(IndexedTreeNode<AccoutingTreeModel>(
                        key: Node3.branch_no, data: Node3));
                    indexedTrrre
                        .elementAt(
                            "${root.branch_no}.${Node1.branch_no}.${Node2.branch_no}")
                        .addAll(IndexNode3);
                    IndexNode4.clear();
                    allAccountingBrach4.clear();
                    allAccountingBrach4.addAll(allAccountingTree.where(
                        (Node4) =>
                            Node4.father_no.compareTo(Node3.branch_no) == 0 &&
                            Node4.father_no.compareTo(Node4.branch_no) != 0));
                    if (allAccountingBrach4.isNotEmpty) {
                      for (var Node4 in allAccountingBrach4) {
                        IndexNode4.clear();
                        IndexNode4.add(IndexedTreeNode<AccoutingTreeModel>(
                            key: Node4.branch_no, data: Node4));
                        indexedTrrre
                            .elementAt(
                                "${root.branch_no}.${Node1.branch_no}.${Node2.branch_no}.${Node3.branch_no}")
                            .addAll(IndexNode4);
                        IndexNode5.clear();
                        allAccountingBrach5.clear();
                        allAccountingBrach5.addAll(allAccountingTree.where(
                            (Node5) =>
                                Node5.father_no.compareTo(Node4.branch_no) ==
                                    0 &&
                                Node5.father_no.compareTo(Node5.branch_no) !=
                                    0));
                      if (allAccountingBrach5.isNotEmpty) {
                        for (var Node5 in allAccountingBrach5) {
                        IndexNode5.clear();
                        IndexNode5.add(IndexedTreeNode<AccoutingTreeModel>(
                          key: Node5.branch_no, data: Node5));
                        indexedTrrre
                          .elementAt(
                            "${root.branch_no}.${Node1.branch_no}.${Node2.branch_no}.${Node3.branch_no}.${Node4.branch_no}")
                          .addAll(IndexNode5);
                        }
                      }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    } //for each
  } //End Function
}
