Feature: Gouvernance et blocage des paiements frauduleux
	En tant que Responsable de la Gouvernance Financière
	Je veux que le système évalue le niveau de risque de chaque paiement
	Afin de bloquer les transactions potentiellement frauduleuses protégeant ainsi l'entreprise

	Scenario: Validation d'un paiement standard sans risque
		Given Un client standard
		And Une commande d'un montant de 5000 euros à destination de la "France"
		When Le client soumet son paiement
		Then Le paiement est accepté par la gouvernance

	Scenario: Exemption de contrôle pour les clients VIP
		Given Un client VIP
		And Une commande d'un montant de 15000 euros à destination de la "Syldavie"
		When Le client soumet son paiement
		Then Le paiement est accepté par la gouvernance grâce au statut VIP
