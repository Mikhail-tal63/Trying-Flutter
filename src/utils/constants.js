const TASK_PRIORITIES = ['urgent', 'important', 'normal'];
const TASK_STATUSES = ['pending', 'in-progress', 'completed', 'archived'];

const LIST_ROLES = ['viewer', 'editor', 'admin'];

const USER_ROLES = ['user', 'admin'];

const ACHIEVEMENT_TYPES = ['first_task', 'organizer', 'achiever', 'early_bird', 'team_player'];

const ACHIEVEMENTS_DEFINITIONS = {
  first_task: {
    title: 'المبتدئ',
    description: 'إكمال أول مهمة',
    target: 1,
  },
  organizer: {
    title: 'منظم',
    description: 'إنشاء 10 مهام',
    target: 10,
  },
  achiever: {
    title: 'المنجز',
    description: 'إكمال 50 مهمة',
    target: 50,
  },
  early_bird: {
    title: 'قبل الموعد',
    description: 'إكمال 10 مهام قبل تاريخ الاستحقاق',
    target: 10,
  },
  team_player: {
    title: 'لاعب جماعي',
    description: 'إكمال 10 مهام داخل قوائم مشتركة',
    target: 10,
  },
};

module.exports = {
  TASK_PRIORITIES,
  TASK_STATUSES,
  LIST_ROLES,
  USER_ROLES,
  ACHIEVEMENT_TYPES,
  ACHIEVEMENTS_DEFINITIONS,
};
