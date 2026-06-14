class OnboardingContent {
  final String title;
  final String description;

  OnboardingContent({
    required this.title,
    required this.description,
  });
}

// Global text step mapping configuration arrays
List<OnboardingContent> onboardingSteps = [
  OnboardingContent(
    title: "Play Fun\nGames!",
    description: "Explore a world of wonder where\nevery tap leads to a new discovery.",
  ),
  OnboardingContent(
    title: "Enjoy Magical\nStories!",
    description: "Dive into adventures that spark\nimagination and creativity.",
  ),
  OnboardingContent(
    title: "Draw & Color Fun",
    description: "Dive into adventures that spark\nimagination and creativity.",
  ),
];