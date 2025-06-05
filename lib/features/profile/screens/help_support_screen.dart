import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aet_app/core/constants/color_constants.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'aet_preparation@astanait.edu.kz',
      query: '',
    );
    await launchUrl(emailLaunchUri);
  }

  void _launchPhone() async {
    final Uri phoneLaunchUri = Uri(scheme: 'tel', path: '+77172645710');
    await launchUrl(phoneLaunchUri);
  }

  void _launchWebsite() async {
    final Uri url = Uri.parse('https://astanait.edu.kz');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.06;
    final verticalSpacing = screenHeight * 0.025;
    final titleFontSize = screenWidth * 0.08;
    final textFontSize = screenWidth * 0.045;
    final iconSize = screenWidth * 0.11;

    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.white,
        foregroundColor: ColorConstants.primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: ColorConstants.primaryColor),
        titleTextStyle: TextStyle(
          color: ColorConstants.primaryColor,
          fontSize: titleFontSize * 0.7,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalSpacing,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: verticalSpacing * 2),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: ColorConstants.primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.support_agent,
                  size: iconSize * 1.5,
                  color: ColorConstants.primaryColor,
                ),
              ),
              SizedBox(height: verticalSpacing),
              Text(
                'Нужна помощь? Мы всегда на связи!',
                style: TextStyle(
                  fontSize: titleFontSize * 0.7,
                  fontWeight: FontWeight.bold,
                  color: ColorConstants.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: verticalSpacing * 0.7),
              Text(
                'Если у вас возникли вопросы или трудности, свяжитесь с нашей службой поддержки любым удобным способом.',
                style: TextStyle(
                  fontSize: textFontSize * 0.85,
                  color: ColorConstants.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: verticalSpacing * 2),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: ColorConstants.primaryColor.withOpacity(0.12),
                  ),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _contactTile(
                        icon: Icons.email,
                        iconColor: ColorConstants.primaryColor,
                        title: 'Email',
                        subtitle: 'aet_preparation@astanait.edu.kz',
                        onTap: _launchEmail,
                      ),
                      const Divider(),
                      _contactTile(
                        icon: Icons.phone,
                        iconColor: Colors.green,
                        title: 'Телефон',
                        subtitle: '+7 (717) 264 57 10',
                        onTap: _launchPhone,
                      ),
                      const Divider(),
                      _contactTile(
                        icon: Icons.access_time,
                        iconColor: Colors.orange,
                        title: 'Время работы',
                        subtitle: 'Пн-Пт: с 9:00 до 18:00',
                      ),
                      const Divider(),
                      _contactTile(
                        icon: Icons.language,
                        iconColor: ColorConstants.primaryColor,
                        title: 'Сайт AITU',
                        subtitle: 'https://astanait.edu.kz',
                        onTap: _launchWebsite,
                      ),
                      const Divider(),
                      _contactTile(
                        icon: Icons.location_on,
                        iconColor: Colors.redAccent,
                        title: 'Адрес',
                        subtitle:
                            'Astana IT University,\nПроспект Мангилик Ел, С1',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: verticalSpacing * 2),
              Text(
                'Мы ценим ваше доверие!\nAITU Support Team',
                style: TextStyle(
                  color: ColorConstants.secondaryTextColor,
                  fontSize: textFontSize * 0.95,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: verticalSpacing * 1.5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(10),
        child: Icon(icon, color: iconColor, size: 28),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 15)),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      horizontalTitleGap: 16,
      minVerticalPadding: 8,
    );
  }
}
