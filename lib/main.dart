import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool data = false;
  int myAmount = 0;
  var myData;
  late Client httpClient;
  late Web3Client ethClient;

  //Ethereum address
  final String myAddress = "0x9Fb05a46051114126CE24873007249EeB03C2c85";

  //url from Infura
  final String blockchainUrl = "https://rinkeby.infura.io/v3/24718854bbf84c779c9fbb61c8ceea82";


  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(blockchainUrl, httpClient);
    getBalance(myAddress);
    print(myAmount);
  }

  Future<DeployedContract> getContract() async {
    //obtain our smart contract using rootbundle to access our json file
    String abiFile = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0x6cB487455EEEAF5C325B6D327fDa387c58cf35db";
    final contract = DeployedContract(ContractAbi.fromJson(abiFile, "ethCoin"), EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  Future<List<dynamic>> query(String name, List<dynamic> args) async {
    final contract = await getContract();
    final function = contract.function(name);
    final result = await ethClient.call(contract: contract, function: function, params: []);
    return result;
  }

  Future<void> getBalance(myAddress) async {
    List<dynamic> resultsA = await query("getBalance", []);
    myData = resultsA[0];
    data = true;
    print(myData);
    setState(() {});
  }

  Future<String> submit(String name, List<dynamic> args) async {
    //obtain private key for write operation
    EthPrivateKey credentials = EthPrivateKey.fromHex("0d31dab84c01af4ad1d2bd74e9a022ef4652096f801ed4271ee1af5321c8e8b8");
    final contract = await getContract();
    final function = contract.function(name);
    final result = await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(contract: contract, function: function, parameters: args),
      chainId: 4,
    );
    return result;
  }

  Future<String> depositCoin(myAddress) async {
    var bigAmount =  BigInt.from(myAmount);
    print(bigAmount);
    var response = await submit("depositBalance", [bigAmount]);

    print('Deposited!');
    print(bigAmount);
    return response;
  }

  Future<String> withDrawCoin(myAddress) async {
    var bigAmount =  BigInt.from(myAmount);
    var response = await submit("withdrawBalance", [bigAmount]);

    print('Withdrawn!');
    print(bigAmount);
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Meta Wallet'),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Balance',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(
            height: 10,
          ),
          data
              ? Center(
                  child: Text(
                  "\$$myData",
                  style: const TextStyle(fontSize: 20),
                ))
              : const Center(child: CircularProgressIndicator()),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter Amount',
              ),
              onChanged: (value){
                myAmount = int.parse(value);
                print('check');
                print(myAmount);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => getBalance(myAddress),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton.icon(
                onPressed: () => depositCoin(myAddress),
                icon: const Icon(Icons.arrow_upward),
                label: const Text('Deposit'),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.green)),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton.icon(
                onPressed: () => withDrawCoin(myAddress),
                icon: const Icon(Icons.arrow_downward),
                label: const Text('Withdraw'),
                style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.red)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
