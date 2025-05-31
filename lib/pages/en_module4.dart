import 'package:aet_app/pages/en_test.dart';
import 'package:flutter/material.dart';

class EnModule4 extends StatelessWidget {
  const EnModule4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "English\ngrammar",
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4280EF),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Module  4 - Relative pronouns",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Relative pronouns introduce relative clauses. The most common relative pronouns are who, whom, whose, which, that. The relative pronoun we use depends on what we are referring to and the type of relative clause",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 25),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(top: 25),
              child: Image.asset('lib/images/en_grammar.png'),
            ),
            const SizedBox(height: 25),
            const Text(
              """(In the examples, the relative pronoun is in brackets to show where it is not essential; the person or thing being referred to is underlined.)
We don’t know the person who donated this money.
We drove past my old school, which is celebrating its 100th anniversary this year.
He went to the school (that) my father went to.
The Kingfisher group, whose name was changed from Woolworths earlier this year, includes about 720 high street shops. Superdrug, which last week announced that it is buying Medicare, is also part of the group.
The parents (whom/who/that) we interviewed were all involved in education in some way.""",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 100), // Дополнительное пространство, чтобы контент не накрывал нижние кнопки
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(25, 25, 25, 25),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C80A0),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Previous",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EnTest()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4280EF),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Go to Test",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
