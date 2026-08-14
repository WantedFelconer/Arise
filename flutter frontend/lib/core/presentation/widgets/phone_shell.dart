import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../design_system/components/arise_simulation_background.dart';

class PhoneShell extends StatelessWidget {
  final Widget child;

  const PhoneShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth <= 450;
            final width = isMobile ? constraints.maxWidth : 390.0;
            final height = isMobile ? constraints.maxHeight : 844.0;
            final radius = isMobile ? 0.0 : 44.0;

            return Container(
              width: width,
              height: height,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.voidEdge,
                borderRadius: BorderRadius.circular(radius),
                border: isMobile
                    ? null
                    : Border.all(color: const Color(0x1F3EE6F5), width: 1.0),
                boxShadow: isMobile
                    ? null
                    : const [
                        BoxShadow(
                          color: Color(0x143EE6F5),
                          blurRadius: 80,
                        ),
                        BoxShadow(
                          color: Color(0xE6000000),
                          blurRadius: 120,
                          offset: Offset(0, 40),
                        ),
                      ],
                gradient: const RadialGradient(
                  center: Alignment(0, -0.4),
                  radius: 1.0,
                  colors: [
                    AppColors.voidCenter,
                    AppColors.voidEdge,
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: Stack(
                  children: [
                    // Global ARISE Matrix Simulation Background
                    const Positioned.fill(
                      child: AriseSimulationBackground(),
                    ),

                    Positioned.fill(child: child),

                    // Top ambient gradient overlay
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 48,
                      child: IgnorePointer(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0x99030712), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom ambient gradient overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 24,
                      child: IgnorePointer(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Color(0xCC030712), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
