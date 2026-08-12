enum MapNodeStatus { locked, available, active, complete }

class MapNode {
  final String id;
  final double x;
  final double y;
  final String label;
  final String rank;
  final String category;
  final MapNodeStatus status;
  final int exp;
  final int progress;
  final String desc;

  const MapNode({
    required this.id,
    required this.x,
    required this.y,
    required this.label,
    required this.rank,
    required this.category,
    required this.status,
    required this.exp,
    required this.progress,
    required this.desc,
  });
}
