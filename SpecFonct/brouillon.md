# Brouillon : User Stories Anti-Fraude

## US principale

En tant que Responsable de la Gouvernance Financière,
je veux que le système évalue le niveau de risque de chaque paiement,
afin de bloquer les transactions potentiellement frauduleuses
et de protéger ainsi l'entreprise.

### Critères d'acceptation

1. Un paiement est refusé lorsque le montant du panier dépasse 10 000 €
   ET que le pays de livraison, évalué selon le registre des embargos, y figure.
2. Lorsqu'un paiement est refusé, le client est notifié du refus de transaction
   pour suspicion de fraude.
3. Un paiement dont le montant ne dépasse pas 10 000 € n'est pas refusé,
   même si le pays de livraison figure au registre des embargos.
4. Un paiement dont le pays de livraison ne figure pas au registre des embargos
   n'est pas refusé, même si le montant dépasse 10 000 €.
5. Un client VIP n'est jamais refusé, quels que soient le montant du panier
   et le pays de livraison.
