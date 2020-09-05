class Call{
  final String callerId;
  final String calleeId;
  final String callerOffer;
  final String callerIce;
  final String calleeAnswer;
  final String calleeIce;
  final bool accepted;

  Call({
    this.callerId,
    this.calleeId,
    this.callerOffer, 
    this.calleeIce, 
    this.calleeAnswer, 
    this.callerIce, 
    this.accepted
  });
}