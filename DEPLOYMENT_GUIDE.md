# Quick Deployment Guide - Performance Optimizations

## Step 1: Deploy Firestore Indexes (REQUIRED)

```bash
# Deploy the indexes to Firebase
firebase deploy --only firestore:indexes

# Check status in Firebase Console
# Go to: Firestore Database > Indexes
# Wait for all indexes to show "Enabled" status (may take 5-10 minutes)
```

## Step 2: Update Firestore Rules (if needed)

Ensure your `firestore.rules` allows the new fields:

```javascript
match /users/{userId} {
  allow read: if request.auth != null;
  allow write: if request.auth.uid == userId;
  
  // Allow transaction service to update earnings
  allow update: if request.auth != null 
    && request.resource.data.diff(resource.data).affectedKeys()
      .hasOnly(['totalEarnings', 'completedTasks']);
}
```

## Step 3: Run Migration Script (ONE-TIME)

Create a temporary script to migrate existing user earnings:

```dart
// Run this once in a Flutter app or Cloud Function
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> migrateUserEarnings() async {
  final firestore = FirebaseFirestore.instance;
  final users = await firestore.collection('users').get();
  
  print('Migrating ${users.docs.length} users...');
  
  for (var userDoc in users.docs) {
    final userId = userDoc.id;
    
    // Get all completed transactions for this user
    final transactions = await firestore
        .collection('transactions')
        .where('runnerId', isEqualTo: userId)
        .where('status', isEqualTo: 'COMPLETED')
        .get();
    
    double totalEarnings = 0;
    for (var txn in transactions.docs) {
      final amount = double.tryParse(txn.data()['amount'] ?? '0') ?? 0;
      totalEarnings += amount;
    }
    
    // Update user document
    await userDoc.reference.update({
      'totalEarnings': totalEarnings,
      'completedTasks': transactions.docs.length,
    });
    
    print('Updated user $userId: ₹$totalEarnings (${transactions.docs.length} tasks)');
  }
  
  print('Migration complete!');
}

// Call this function once
void main() async {
  await migrateUserEarnings();
}
```

## Step 4: Test the Changes

### Test Location Tracking
1. Start a task as a runner
2. Observe location updates happen every 30 seconds (not continuously)
3. Check Firestore writes in Firebase Console - should be ~2 writes/minute

### Test Earnings Calculation
1. Complete a task
2. Check runner's profile - totalEarnings should update immediately
3. Verify no lag in earnings screen

### Test Pagination
1. Create 30+ tasks
2. Scroll through task list
3. Verify smooth loading with 20 items per page

## Step 5: Monitor Performance

### Firebase Console Checks
1. **Firestore Usage**: Monitor reads/writes - should see 70-80% reduction
2. **Index Status**: All indexes should show "Enabled"
3. **Query Performance**: Check query execution times in Firestore logs

### App Performance
1. Task list load time: Should be <500ms
2. Earnings screen load: Should be <100ms
3. Location updates: Should batch every 30 seconds

## Step 6: Rollback Plan (if needed)

If issues occur, you can rollback:

```bash
# Revert to previous code
git revert HEAD

# Keep indexes (they don't hurt)
# Or delete them in Firebase Console if needed
```

## Common Issues & Solutions

### Issue: "Index not found" error
**Solution**: Wait for indexes to build (5-10 minutes). Check Firebase Console.

### Issue: Earnings showing 0
**Solution**: Run the migration script to populate existing user earnings.

### Issue: Location not updating
**Solution**: Check that location permissions are granted and service is running.

### Issue: Pagination not working
**Solution**: Ensure queries match the created indexes (same field order).

## Performance Metrics to Track

Monitor these in Firebase Console:

- **Firestore Reads**: Should decrease by ~80%
- **Firestore Writes**: Should decrease by ~67% (location updates)
- **Query Latency**: Should be <500ms for all queries
- **Monthly Cost**: Should decrease by ~70%

## Next Steps (Optional Enhancements)

1. **Add Caching**: Implement Hive for offline support
2. **Image Optimization**: Use cached_network_image
3. **Cloud Functions**: Set up automated cleanup
4. **Performance Monitoring**: Add Firebase Performance SDK

## Support

If you encounter issues:
1. Check Firebase Console for index status
2. Review Firestore rules for permission errors
3. Check app logs for error messages
4. Verify migration script completed successfully
