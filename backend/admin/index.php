<!DOCTYPE html>
<html lang="fr">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Admin - SafeGuardian</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        :root {
            --primary: #667eea;
            --primary-dark: #764ba2;
            --accent: #a855f7;
            --success: #10b981;
            --danger: #ef4444;
            --bg: #f8fafc;
            --card: #ffffff;
            --text: #1e293b;
            --text-muted: #64748b;
            --border: #e2e8f0;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: var(--bg);
            color: var(--text);
        }

        .navbar {
            background: var(--card);
            border-bottom: 1px solid var(--border);
            padding: 16px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            position: sticky;
            top: 0;
            z-index: 100;
        }

        .navbar-brand {
            font-size: 20px;
            font-weight: 700;
            background: linear-gradient(135deg, var(--primary), var(--accent));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .navbar-user {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .user-info {
            text-align: right;
        }

        .user-name {
            font-weight: 600;
            font-size: 14px;
        }

        .user-email {
            font-size: 12px;
            color: var(--text-muted);
        }

        .logout-btn {
            padding: 8px 16px;
            background: var(--danger);
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .logout-btn:hover {
            opacity: 0.9;
            transform: translateY(-1px);
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 32px 24px;
        }

        .page-header {
            margin-bottom: 32px;
        }

        .page-title {
            font-size: 32px;
            font-weight: 700;
            margin-bottom: 8px;
        }

        .page-subtitle {
            color: var(--text-muted);
            font-size: 14px;
        }

        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 32px;
        }

        .metric-card {
            background: var(--card);
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            transition: all 0.3s ease;
        }

        .metric-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
        }

        .metric-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 16px;
        }

        .metric-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 24px;
        }

        .metric-badge {
            padding: 4px 8px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
        }

        .metric-badge.positive {
            background: var(--success);
            color: white;
        }

        .metric-badge.negative {
            background: var(--danger);
            color: white;
        }

        .metric-value {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 8px;
        }

        .metric-label {
            font-size: 14px;
            color: var(--text-muted);
        }

        .section {
            background: var(--card);
            border-radius: 16px;
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
        }

        .section-title {
            font-size: 18px;
            font-weight: 700;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .section-title::before {
            content: '';
            width: 4px;
            height: 24px;
            background: linear-gradient(135deg, var(--primary), var(--accent));
            border-radius: 2px;
        }

        .health-item {
            margin-bottom: 16px;
        }

        .health-label {
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            font-size: 14px;
        }

        .health-bar {
            width: 100%;
            height: 8px;
            background: var(--border);
            border-radius: 4px;
            overflow: hidden;
        }

        .health-fill {
            height: 100%;
            background: linear-gradient(90deg, var(--primary), var(--accent));
            border-radius: 4px;
            transition: width 0.3s ease;
        }

        .activity-item {
            padding: 16px;
            border-radius: 12px;
            background: var(--bg);
            margin-bottom: 12px;
            display: flex;
            gap: 16px;
            align-items: flex-start;
        }

        .activity-icon {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            display: flex;
            justify-content: center;
            align-items: center;
            font-size: 20px;
            flex-shrink: 0;
        }

        .activity-content {
            flex: 1;
        }

        .activity-title {
            font-weight: 600;
            font-size: 14px;
            margin-bottom: 4px;
        }

        .activity-desc {
            font-size: 13px;
            color: var(--text-muted);
            margin-bottom: 4px;
        }

        .activity-time {
            font-size: 12px;
            color: var(--text-muted);
        }

        .loading {
            text-align: center;
            padding: 40px 20px;
            color: var(--text-muted);
        }

        .spinner {
            display: inline-block;
            width: 40px;
            height: 40px;
            border: 4px solid var(--border);
            border-top: 4px solid var(--primary);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% {
                transform: rotate(0deg);
            }

            100% {
                transform: rotate(360deg);
            }
        }

        @media (max-width: 768px) {
            .navbar {
                flex-direction: column;
                gap: 16px;
            }

            .metrics-grid {
                grid-template-columns: 1fr;
            }

            .page-title {
                font-size: 24px;
            }

            .container {
                padding: 16px 12px;
            }
        }
    </style>
</head>

<body>
    <nav class="navbar">
        <div class="navbar-brand">🛡️ SafeGuardian Admin</div>
        <div class="navbar-user">
            <div class="user-info">
                <div class="user-name" id="adminName">Admin</div>
                <div class="user-email" id="adminEmail">admin@safeguardian.com</div>
            </div>
            <form action="logout.php" method="POST" style="margin: 0;">
                <button type="submit" class="logout-btn">Déconnexion</button>
            </form>
        </div>
    </nav>

    <div class="container">
        <div class="page-header">
            <h1 class="page-title">Tableau de Bord Administrateur</h1>
            <p class="page-subtitle">Suivi en temps réel des métriques système et utilisateurs</p>
        </div>

        <!-- Métriques principales -->
        <div class="metrics-grid" id="metricsGrid">
            <div class="loading">
                <div class="spinner"></div>
                <p>Chargement des données...</p>
            </div>
        </div>

        <!-- Santé du système -->
        <div class="section">
            <h2 class="section-title">Santé du Système</h2>
            <div id="healthContainer" class="loading">
                <div class="spinner"></div>
            </div>
        </div>

        <!-- Activités récentes -->
        <div class="section">
            <h2 class="section-title">Activités Récentes</h2>
            <div id="activityContainer" class="loading">
                <div class="spinner"></div>
            </div>
        </div>
    </div>

    <script>
        // Charger les données admin
        async function loadAdminData() {
            try {
                const response = await fetch('/admin/api/metrics.php?action=all');
                const data = await response.json();

                renderMetrics(data);
                renderHealth(data.system_health);
                renderActivity(data.recent_activity);
            } catch (error) {
                console.error('Erreur:', error);
                document.getElementById('metricsGrid').innerHTML = '<p style="grid-column: 1/-1; text-align: center; color: #ef4444;">Erreur lors du chargement des données</p>';
            }
        }

        function renderMetrics(data) {
            const metrics = [{
                    icon: '👥',
                    title: 'Utilisateurs Actifs',
                    value: data.users.active_users || 0,
                    change: data.users.change_text || '+0%',
                    positive: true
                },
                {
                    icon: '⚠️',
                    title: 'Alertes Aujourd\'hui',
                    value: data.alerts.today_alerts || 0,
                    change: '-2.3%',
                    positive: true
                },
                {
                    icon: '🛡️',
                    title: 'Incidents Critiques',
                    value: data.incidents.critical_incidents || 0,
                    change: '+1 nouveau',
                    positive: false
                },
                {
                    icon: '✓',
                    title: 'Contacts Vérifiés',
                    value: data.contacts.verified_contacts || 0,
                    change: data.contacts.change_text || '+0%',
                    positive: true
                }
            ];

            const html = metrics.map(m => `
                <div class="metric-card">
                    <div class="metric-header">
                        <div class="metric-icon" style="background: linear-gradient(135deg, var(--primary), var(--accent)); color: white;">${m.icon}</div>
                        <span class="metric-badge ${m.positive ? 'positive' : 'negative'}">${m.change}</span>
                    </div>
                    <div class="metric-value">${m.value}</div>
                    <div class="metric-label">${m.title}</div>
                </div>
            `).join('');

            document.getElementById('metricsGrid').innerHTML = html;
        }

        function renderHealth(health) {
            const items = [{
                    label: 'Base de Données',
                    key: 'database'
                },
                {
                    label: 'API Serveur',
                    key: 'api'
                },
                {
                    label: 'Notifications',
                    key: 'notifications'
                },
                {
                    label: 'Géolocalisation',
                    key: 'geolocation'
                }
            ];

            const html = items.map(item => {
                const h = health[item.key];
                return `
                    <div class="health-item">
                        <div class="health-label">
                            <span>${item.label}</span>
                            <span>${h.percentage}%</span>
                        </div>
                        <div class="health-bar">
                            <div class="health-fill" style="width: ${h.percentage}%"></div>
                        </div>
                    </div>
                `;
            }).join('');

            document.getElementById('healthContainer').innerHTML = html;
        }

        function renderActivity(activities) {
            if (!activities || activities.length === 0) {
                document.getElementById('activityContainer').innerHTML = '<p style="text-align: center; color: #94a3b8;">Aucune activité récente</p>';
                return;
            }

            const html = activities.map(a => `
                <div class="activity-item">
                    <div class="activity-icon" style="background: linear-gradient(135deg, var(--primary), var(--accent)); color: white;">📊</div>
                    <div class="activity-content">
                        <div class="activity-title">${a.description}</div>
                        <div class="activity-time">${new Date(a.timestamp).toLocaleString('fr-FR')}</div>
                    </div>
                </div>
            `).join('');

            document.getElementById('activityContainer').innerHTML = html;
        }

        // Charger les infos admin
        async function loadAdminInfo() {
            try {
                const response = await fetch('/admin/api/profile.php');
                const data = await response.json();
                document.getElementById('adminName').textContent = data.name || 'Admin';
                document.getElementById('adminEmail').textContent = data.email || 'admin@safeguardian.com';
            } catch (error) {
                console.error('Erreur:', error);
            }
        }

        // Charger au démarrage
        loadAdminData();
        loadAdminInfo();

        // Rafraîchir les données toutes les 30 secondes
        setInterval(loadAdminData, 30000);
    </script>
</body>

</html>