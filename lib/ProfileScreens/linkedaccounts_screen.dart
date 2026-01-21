import 'package:flutter/material.dart';
import 'package:fluttrr/Constants/listdata.dart';

class LinkedaccountsScreen extends StatefulWidget {
  const LinkedaccountsScreen({super.key});

  @override
  State<LinkedaccountsScreen> createState() => _LinkedaccountsScreenState();
}

class _LinkedaccountsScreenState extends State<LinkedaccountsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        shadowColor: Color(0xffF1F1F1),
        surfaceTintColor: Theme.of(context).cardColor,
        backgroundColor: Theme.of(context).cardColor,
        toolbarHeight: 70,
        leading: Icon(
          Icons.arrow_back,
          color: Theme.of(context).primaryColor,
        ),
        title: Text(
          'Linked Accounts',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Column(
              children: [
                ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: linkedAccountsData.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Image.asset(
                          linkedAccountsData[index].image,
                          height: 33,
                        ),
                        trailing: Container(
                          height: 30,
                          width: 70,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Color(0xffF1F1F1)),
                          child: Center(
                            child: Text(
                              linkedAccountsData[index].linkButton,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                        title: Text(
                          linkedAccountsData[index].name,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          linkedAccountsData[index].discription,
                          style: TextStyle(
                              fontSize: 15,
                              color: Theme.of(context).indicatorColor),
                        ),
                      );
                    }),
                SizedBox(
                  height: 15,
                ),
              ],
            )),
      ),
    );
  }
}
