function localDateStr(d) {
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${y}-${m}-${day}`;
}

function dateOnlyStr(d) {
    return localDateStr(d);
}

function calculateStreak(logs) {
    if (!logs || logs.length === 0) return 0;

    const completedDates = logs
        .filter(log => log.completed)
        .map(log => dateOnlyStr(new Date(log.date)))
        .sort()
        .reverse();

    if (completedDates.length === 0) return 0;

    const now = new Date();
    const today = localDateStr(now);
    const yesterdayDate = new Date(now);
    yesterdayDate.setDate(yesterdayDate.getDate() - 1);
    const yesterday = localDateStr(yesterdayDate);

    if (completedDates[0] !== today && completedDates[0] !== yesterday) {
        return 0;
    }

    let streak = 1;
    let currentDate = new Date(completedDates[0]);

    for (let i = 1; i < completedDates.length; i++) {
        const prevDate = dateOnlyStr(new Date(currentDate.getTime() - 86400000));
        if (completedDates[i] === prevDate) {
            streak++;
            currentDate = new Date(completedDates[i]);
        } else {
            break;
        }
    }

    return streak;
}

function calculateMaxStreak(logs) {
    if (!logs || logs.length === 0) return 0;

    const completedDates = logs
        .filter(log => log.completed)
        .map(log => dateOnlyStr(new Date(log.date)))
        .sort();

    if (completedDates.length === 0) return 0;

    let maxStreak = 1;
    let currentStreak = 1;

    for (let i = 1; i < completedDates.length; i++) {
        const prevDate = dateOnlyStr(new Date(new Date(completedDates[i - 1]).getTime() + 86400000));
        if (completedDates[i] === prevDate) {
            currentStreak++;
            maxStreak = Math.max(maxStreak, currentStreak);
        } else {
            currentStreak = 1;
        }
    }

    return maxStreak;
}

function calculateStreakFromLogs(logs) {
    return calculateStreak(logs);
}

function calculateMaxStreakFromLogs(logs) {
    return calculateMaxStreak(logs);
}

module.exports = {
    calculateStreak,
    calculateMaxStreak,
    calculateStreakFromLogs,
    calculateMaxStreakFromLogs,
    localDateStr,
    dateOnlyStr
};