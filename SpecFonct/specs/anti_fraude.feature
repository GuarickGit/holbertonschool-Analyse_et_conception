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

	Scenario Outline: Blocage par la gouvernance selon la matrice de risque
		Given Un client standard avec une commande de <montant_cmd> euros vers la <destination>
		When Le client soumet son paiement
		Then Le paiement est <resultat> par la gouvernance

		Examples:
			| montant_cmd | destination | resultat |
			| 5000        | "France"    | accepté  |
			| 9999        | "Syldavie"  | accepté  |
			| 10000       | "France"    | accepté  |
			| 10000       | "Syldavie"  | accepté  |
			| 10001       | "France"    | accepté  |
			| 10001       | "Syldavie"  | refusé   |
			| 15000       | "Bordurie"  | refusé   |
