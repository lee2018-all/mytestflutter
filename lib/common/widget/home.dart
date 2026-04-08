import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../map/common_map.dart';
import 'information.dart';

class HomeWidget extends StatefulWidget {
  @override
  State<HomeWidget> createState() => _HomeWidget();
}

class _HomeWidget extends State<HomeWidget> {
  int score_num = 0;
  int score_status = 0;

  late List<int> array2;

  @override
  void initState() {
    //
    super.initState();
    getStatus();
  }

  void getStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? str1 = prefs.getString('score_num');
    if (str1 != null && str1!.isNotEmpty) {
      array2 = RegExp(
        r'\d+',
      ).allMatches(str1!).map((match) => int.parse(match.group(0)!)).toList();
      if (array2.length > 0) {
        score_num = array2[0];
      }
    }
    score_status = score_num > 500 ? 1 : 2;
    score_status = score_num == 0 ? 0 : score_status;

    setState(() {
      score_num;
    });
  }

  int selectedLoanType = 0;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var bottom = MediaQuery.of(context).padding.bottom;
    var top = MediaQuery.of(context).padding.top;

    return Container(
      width: width,
      height: height - 49 - bottom,
      decoration: BoxDecoration(color: main_color),
      child: Padding(
        padding: EdgeInsets.only(top: top),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 50, left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('images/avata.png', width: 40, height: 40),
                    SizedBox(width: 20),
                    Text(
                      'Welcome back',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),

                Container(
                  width: width - 32,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/ground.png'),
                      fit: BoxFit.fill,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  margin: EdgeInsets.only(top: 40, right: 16, left: 0),
                  padding: EdgeInsets.only(top: 25, left: 16, bottom: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app_appName,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),

                      SizedBox(height: 4),
                      Text(
                        'Get your credit score & \npersonalized credit insights!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 24),
                      InkWell(
                        onTap: () {
                          if (score_num == 0) getInfoFunction();
                        },
                        child: Container(
                          padding: EdgeInsets.only(
                            top: 12,
                            bottom: 12,
                            left: 20,
                            right: 20,
                          ),
                          decoration: BoxDecoration(
                            color: score_num > 0
                                ? Color(0xffA496E9)
                                : main_color,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: Colors.white,
                              width: score_num > 0 ? 1 : 0,
                            ),
                          ),
                          child: Wrap(
                            children: [
                              Text(
                                score_num > 0 ? 'Score Displayed' : 'Check Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 12),
                              Image.asset(
                                score_num > 0
                                    ? 'images/complete.png'
                                    : 'images/star.png',
                                width: 25,
                                height: 25,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  child: SingleChildScrollView(
                    child: Row(
                      children: [
                        _buildMedicalLoanButton('Personal Loan', 0),
                        _buildMedicalLoanButton('Wheeler Loan', 1),
                        _buildMedicalLoanButton('Instant Loan', 2),
                        _buildMedicalLoanButton('Gold Loan', 3),
                      ],
                    ),
                    scrollDirection: Axis.horizontal,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: ScoreProgressBar(
                    score: score_num == 0 ? 300 : score_num,
                  ),
                ),
                if (score_num > 0)
                  Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                          top: 34,
                          left: 0,
                          right: 15,
                          bottom: 30,
                        ),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('images/bg.png'),
                            fit: BoxFit.cover, //
                          ),

                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(4),
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),

                            child: Text(
                              getdes(score_num),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w300,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalLoanButton(String title, int pos) {
    bool isSelected = selectedLoanType == pos;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLoanType = pos;
          try {
            if (array2 != null && array2.length > 0) {
              score_num = array2[selectedLoanType];
            }
          } catch (e) {}
        });
      },
      child: Container(
        padding: EdgeInsets.only(left: 12, right: 12),
        margin: EdgeInsets.only(right: 8, top: 20),

        decoration: BoxDecoration(
          color: isSelected ? Color(0x3056CCE2) : Colors.transparent,
          borderRadius: BorderRadius.circular(30), //
          border: Border.all(
            color: isSelected ? Color(0xff56CCE2) : Color(0xff2A3952),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 7, bottom: 7),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Color(0xff56CCE2) : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  void getInfoFunction() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Information()),
    );
  }
  String getdes(int score) {
    if (score < 499) return 'This score reflects significant credit mismanagement—late payments, defaults, or multiple unresolved debts. Lenders view this as high-risk; loan/credit card approvals are rare, and any offers come with exorbitant interest rates. To improve: Settle outstanding dues, make timely payments, and avoid new credit inquiries. Focus on rebuilding trust with lenders over 6–12 months.';
    if (score < 599) return 'A fair score indicates inconsistent repayment history or limited credit exposure. Lenders may approve small-ticket loans but with strict terms (higher interest, lower limits). Key issues: Occasional late payments, maxed-out credit lines, or short credit history. Improve by paying bills on time, reducing credit utilization, and maintaining 1–2 active, responsible credit accounts.';
    if (score < 699) return 'This score signals reliable credit behavior—regular on-time payments and manageable debt. Most lenders approve loans/credit cards with competitive interest rates. You qualify for standard credit products but may miss premium offers. Sustain by avoiding late payments, keeping credit utilization below 30%, and diversifying credit (e.g., mix of loans and cards).';
    if (score < 799) return 'A very good score reflects excellent credit discipline—long, positive repayment history, low debt, and minimal inquiries. You qualify for top-tier credit offers: low-interest rates, high credit limits, and premium cards. Lenders perceive you as a trustworthy borrower. Maintain by continuing timely payments, limiting new credit, and monitoring your credit report for errors.';
    if (score < 901) return 'The highest CIBIL tier, indicating flawless credit management—consistent on-time payments, long credit history, and optimal debt-to-credit ratio. You get exclusive benefits: lowest interest rates, instant loan approvals, and premium financial products. Lenders prioritize your applications. Preserve by avoiding defaults, keeping credit utilization low, and retaining old, well-managed credit accounts.';
    return '';
  }
}

class ScoreProgressBar extends StatelessWidget {
  final int score; //
  final int totalSteps; //
  final double stepWidth;
  final double stepHeight;
  final double spacing;

  const ScoreProgressBar({
    Key? key,
    required this.score,
    this.totalSteps = 20,
    this.stepWidth = 13,
    this.stepHeight = 32,
    this.spacing = 2,
  }) : assert(
         score >= 300 && score <= 900,
         'Score must be between 300 and 900',
       ),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final int activeSteps = ((score - 300) / 600 * (totalSteps - 1))
        .round()
        .clamp(0, totalSteps - 1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 28),

        Text(
          '${score == 300 ? 0 : score.toStringAsFixed(0)}',
          style: TextStyle(
            color: score > 300 ? Color(0xff06D176) : Color(0xff727B8F),
            fontSize: 30, //
            fontWeight: FontWeight.bold, //
          ),
        ),
        //
        if (score > 300)
          Text(
            _getCreditLevel(score),
            style: TextStyle(
              color: Color(0xff727B8F),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        if (score == 300)
          Text(
            'Risk Scoring',
            style: TextStyle(
              color: Color(0xff727B8F),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),

        SizedBox(height: 12),

        Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalSteps, (index) {
              final bool isActive = index <= activeSteps;
              final double progressPercent = index / (totalSteps - 1);
              final Color stepColor = _getStepColor(progressPercent, isActive);

              return Container(
                width: stepWidth,
                height: stepHeight,
                margin: EdgeInsets.only(right: spacing),
                decoration: BoxDecoration(
                  color: stepColor,
                  borderRadius: BorderRadius.circular(stepHeight / 2),
                ),
              );
            }),
          ),
        ),

        SizedBox(height: 8),

        //
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildScoreLabel(300),
              _buildScoreLabel(600),
              _buildScoreLabel(900),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreLabel(int scoreValue) {
    return Text(
      scoreValue.toString(),
      style: TextStyle(
        color: Color(0xff727B8F),
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  //
  Color _getStepColor(double progressPercent, bool isActive) {
    if (!isActive) {
      return Color(0xFFE8E8E8).withOpacity(0.5);
    }

    if (score == 300) {
      return Color(0xFFE8E8E8).withOpacity(0.5);
    }

    if (progressPercent < 0.5) {
      //
      return Color.lerp(
        Color(0xFF856CF5), //
        Color(0xFF5EE0F8), //
        progressPercent * 2, // -1
      )!;
    } else {
      //
      return Color.lerp(
        Color(0xFF5EE0F8), //
        Color(0xFF2AF599), //
        (progressPercent - 0.5) * 2, // -1
      )!;
    }
  }

  Color _getStepColorSmooth(double progressPercent, bool isActive) {
    if (!isActive) {
      return Color(0xFFE8E8E8).withOpacity(0.5);
    }

    if (score == 300) {
      return Color(0xFFE8E8E8).withOpacity(0.5);
    }

    if (progressPercent < 0.33) {
      //
      return Color.lerp(
        Color(0xFF856CF5), //
        Color(0xFF7BA5F6), //
        progressPercent * 3, //
      )!;
    } else if (progressPercent < 0.66) {
      // 33%-66%:
      return Color.lerp(
        Color(0xFF7BA5F6), //
        Color(0xFF5EE0F8), //
        (progressPercent - 0.33) * 3, // -1
      )!;
    } else {
      // 66%-100%:
      return Color.lerp(
        Color(0xFF5EE0F8), //
        Color(0xFF2AF599), //
        (progressPercent - 0.66) * 3, // -1
      )!;
    }
  }

  //
  String _getCreditLevel(int score) {
    if (score < 499) return 'Poor';
    if (score < 599) return 'Fair';
    if (score < 699) return 'Good';
    if (score < 799) return 'Very Good';
    if (score < 901) return 'Excellent Credit';
    return '';
  }

}
