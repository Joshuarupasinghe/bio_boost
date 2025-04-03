import 'dart:ui';
import 'package:flutter/material.dart';

class BenefitsPage extends StatelessWidget {
  const BenefitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.black, // Darker background for contrast
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: const [
          BenefitTile(
            title: "Resource conservation",
            description:
                "Recycling reduces the need for raw materials and preserves natural resources such as trees, water, and minerals.",
          ),
          BenefitTile(
            title: "Energy savings",
            description:
                "Recycling uses less energy than producing new products, lowering greenhouse gas emissions.",
          ),
          BenefitTile(
            title: "Waste reduction",
            description:
                "Both recycling and composting of waste from landfills reduces pollution and extends the lifetime of the landfill.",
          ),
          BenefitTile(
            title: "Soil health",
            description:
                "Composting enriches soil with nutrients, improves plant growth, and reduces the need for chemical fertilizers.",
          ),
          BenefitTile(
            title: "Climate effect",
            description:
                "Composting reduces methane emissions from landfills, a potent greenhouse gas contributing to climate change.",
          ),
          BenefitTile(
            title: "Economic benefits",
            description:
                "Recycling creates jobs in waste management and production industries, and increases local economies.",
          ),
          BenefitTile(
            title: "Circular economy",
            description:
                "Recycling promotes recycling materials, reduces waste and promotes sustainable production cycles.",
          ),
          BenefitTile(
            title: "Cost savings",
            description:
                "Composting reduces waste costs for households and municipalities.",
          ),
          BenefitTile(
            title: "Pollution prevention",
            description:
                "Recycling reduces coal and pollution, and keeps ecosystems cleaner and healthier.",
          ),
          BenefitTile(
            title: "Community engagement",
            description:
                "Both practices encourage environmentally friendly habits and community engagement in sustainability efforts.",
          ),
        ],
      ),
    );
  }
}

class BenefitTile extends StatefulWidget {
  final String title;
  final String description;

  const BenefitTile({required this.title, required this.description, super.key});

  @override
  State<BenefitTile> createState() => _BenefitTileState();
}

class _BenefitTileState extends State<BenefitTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[850],
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            widget.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _isExpanded ? Colors.teal : Colors.white,
              fontSize: 16,
            ),
          ),
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14), // Extra top padding
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey[700]!,
                    Colors.grey[800]!,
                    Colors.grey[850]!,
                    Colors.grey[900]!,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.33, 0.66, 1.0],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Padding(
                  padding: const EdgeInsets.all(2.0), // Extra space to prevent cutoff
                  child: Text(
                    widget.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.left,
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
