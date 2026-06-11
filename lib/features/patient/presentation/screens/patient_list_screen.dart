import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/patient_provider.dart';
import '../widgets/cached_patient_list_view.dart';

class PatientListScreen extends ConsumerStatefulWidget {
  const PatientListScreen({super.key});

  @override
  ConsumerState<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends ConsumerState<PatientListScreen> {
  
  @override
  void initState() {
    super.initState();
    
    // 🌟 Screen ထဲသို့ ဝင်ဝင်ချင်း (Widget Tree ဆောက်ပြီးစီးချိန်) တွင်
    // ဆာဗာမှ ဒေတာများကို အလိုအလျောက် Fetch လုပ်ပြီး Cache ရန် လှမ်းခေါ်ခြင်း
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDataSilently();
    });
  }

  Future<void> _fetchDataSilently() async {
    // Controller ထဲက Sync Function ကို လှမ်းခေါ်သည်
    // (အင်တာနက်မရှိပါကလည်း Repository ထဲက try-catch ကြောင့် Error တက်ပြီး App Crashing ဖြစ်မသွားပါ)
    await ref.read(patientFormControllerProvider.notifier).syncFromServer();
  }

  @override
  Widget build(BuildContext context) {
    // Fetch လုပ်နေစဉ် Refresh Indicator ပြသရန်အတွက် Form State ကို Watch လုပ်ထားခြင်း
    final formState = ref.watch(patientFormControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('စက်ထဲရှိ လူနာမှတ်တမ်းများ'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          // လက်動 (Manual) ပြန်ဆွဲချင်ရင်လည်း ဆွဲလို့ရအောင် ခလုတ်အဟောင်းကို ချန်ထားပေးပါမည်
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'ဒေတာများကို ပြန်လည်ဆန်းသစ်ရန်',
            onPressed: () => _fetchDataSilently(),
          )
        ],
      ),
      // 🔄 အသုံးပြုသူက အပေါ်ကနေ အောက်သို့ ဆွဲချလိုက်လျှင်လည်း ဒေတာပြန်ဆွဲပေးမည့် Pull-to-Refresh စနစ်
      body: RefreshIndicator(
        onRefresh: () => _fetchDataSilently(),
        child: SingleChildScrollView(
          // Pull-to-refresh အလုပ်လုပ်ရန် စာရင်းနည်းနေလည်း အမြဲ Scroll ဆွဲလို့ရအောင် လုပ်ထားခြင်း
          physics: const AlwaysScrollableScrollPhysics(), 
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // ဆာဗာကနေ ဒေတာဆွဲနေချိန်တွင် အပေါ်ဆုံး၌ သေးငယ်သော Loading Bar လေး ပြပေးခြင်း
              if (formState.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: LinearProgressIndicator(color: Colors.teal),
                ),
                
              // 📁 ဒေတာများကို ဖတ်ပြမည့် လက်ရှိ Cache List Widget
              const CachedPatientListView(),
            ],
          ),
        ),
      ),
    );
  }
}