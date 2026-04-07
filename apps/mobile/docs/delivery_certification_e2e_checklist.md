# Delivery Certification E2E Checklist

Date: __________
Tester: __________
Build: __________
Device: __________

## Scope
This checklist validates the full required flow:
Walker onboarding -> Delivery training -> Final exam (100%) -> Certification unlock -> Courier opportunities -> Delivery acceptance.

## Preconditions
- Sign in as a non-certified walker account.
- Ensure network access to Firebase.
- Start app from mobile project:
  - flutter run -d windows

## Automated Gate Snapshot
- Date: 2026-04-06
- Targeted analyze on delivery and onboarding files: PASS
- Full flutter test suite: PASS (18/18)

## Manual Flow Steps

1. Open Walker onboarding screen.
Expected: Delivery certification card is visible and marked required.
Result: [ ] Pass [ ] Fail
Notes: ______________________________

2. Fill required onboarding fields without completing delivery certification and submit.
Expected: Submission is blocked with a message requiring delivery training and final exam.
Result: [ ] Pass [ ] Fail
Notes: ______________________________

3. Tap Open Training from the blocker action.
Expected: App navigates to Delivery Certification screen.
Result: [ ] Pass [ ] Fail
Notes: ______________________________

4. Open a required module that has a quiz.
Expected: Module shows quiz CTA and does not show manual mark-complete button.
Result: [ ] Pass [ ] Fail
Notes: ______________________________

5. Complete module quiz with passing score (>=80%).
Expected: Module becomes complete and training progress updates.
Result: [ ] Pass [ ] Fail
Notes: ______________________________

6. Repeat until all required modules are complete.
Expected: Final exam becomes unlocked.
Result: [ ] Pass [ ] Fail
Notes: ______________________________

7. Take final certification exam and score below 100%.
Expected: Certification remains locked.
Result: [ ] Pass [ ] Fail
Notes: ______________________________

8. Retake final certification exam and score 100%.
Expected: certifiedForDelivery true and delivery mode unlocked.
Result: [ ] Pass [ ] Fail
Notes: ______________________________

9. Return to walker onboarding and submit again.
Expected: Onboarding submission succeeds and includes delivery certification metadata.
Result: [ ] Pass [ ] Fail
Notes: ______________________________

10. Open Courier Opportunities as the same user.
Expected: Certification blocker is no longer shown; jobs list is accessible.
Result: [ ] Pass [ ] Fail
Notes: ______________________________

11. Accept an open delivery.
Expected: Acceptance succeeds and navigates to active delivery.
Result: [ ] Pass [ ] Fail
Notes: ______________________________

12. Negative access check with uncertified account.
Expected: Opportunities screen blocked and repository-level acceptance denied.
Result: [ ] Pass [ ] Fail
Notes: ______________________________

## Exit Criteria
- All steps pass, or any failures are documented with reproduction details and screenshots.
- If any fail, file bug with exact step number, account used, and timestamp.
