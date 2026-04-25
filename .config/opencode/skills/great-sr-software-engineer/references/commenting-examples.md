# Commenting Style — Examples

Reference for the `great-sr-software-engineer` skill's Code Commenting Style section.
Examples below use TypeScript and Python, but the principles apply to any language.

## Table of Contents

1. [Restating the obvious (bad)](#1-restating-the-obvious--bad)
2. [Names over comments (good)](#2-names-over-comments--good)
3. [Business rules (good comments)](#3-business-rules--good)
4. [Workarounds (good comments)](#4-workarounds--good)
5. [Non-trivial algorithms (good comments)](#5-non-trivial-algorithms--good)
6. [Complex regex (good comments)](#6-complex-regex--good)
7. [Trade-off explanations (good comments)](#7-trade-off-explanations--good)
8. [TODO / FIXME with context](#8-todo--fixme-with-context)
9. [Cleanup — before and after](#9-cleanup--before-and-after)

---

## 1. Restating the obvious — BAD

### TypeScript

```ts
// This function calculates the total price of all items in the cart
// by iterating through each item and multiplying its price by quantity
function calculateTotal(items: CartItem[]): number {
  // Initialize total to 0
  let total = 0;
  // Loop through each item
  for (const item of items) {
    // Add price times quantity
    total += item.price * item.quantity;
  }
  // Return the total
  return total;
}
```

### Python

```python
# This function calculates the total price of cart items
def calculate_total(items):
    # Initialize total
    total = 0
    # Loop through items
    for item in items:
        # Add price times quantity
        total += item.price * item.quantity
    # Return total
    return total
```

**Why it's bad:** every comment restates what the next line already says. Reading
either of these takes longer than reading the code alone would have.

---

## 2. Names over comments — GOOD

### TypeScript

```ts
function calculateCartTotal(items: CartItem[]): number {
  return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}
```

### Python

```python
def calculate_cart_total(items: list[CartItem]) -> float:
    return sum(item.price * item.quantity for item in items)
```

**Why it works:** the function name states intent and the body is short enough to
read at a glance. No narration needed.

---

## 3. Business rules — GOOD

### TypeScript

```ts
// Reports must use Bangkok time, not server time — finance compares these against
// BKK office-hour transactions.
const reportDate = toBangkokTime(new Date());
```

### Python

```python
# Skip weekends: bank settlement only runs Mon–Fri, so transactions on Sat/Sun
# get posted on the next Monday.
if is_weekend(txn_date):
    txn_date = next_business_day(txn_date)
```

**Why it works:** the rule comes from outside the code (finance team, bank policy).
A new reader has no way to discover it without the comment.

---

## 4. Workarounds — GOOD

### TypeScript

```ts
// Safari < 16 crashes on lookbehind regex. Fallback to split() until we drop
// support for older iOS Safari.
const parts = isSafari() ? value.split('-') : value.match(REGEX_WITH_LOOKBEHIND);
```

### Python

```python
# requests leaks the connection if we don't call .close() explicitly when
# streaming is True. See requests/issues/3912.
with session.get(url, stream=True) as resp:
    process(resp)
```

**Why it works:** the code looks weird on purpose. The comment stops the next
engineer from "cleaning it up" and reintroducing the bug.

---

## 5. Non-trivial algorithms — GOOD

### TypeScript

```ts
// Floyd's cycle detection — tortoise & hare. Detects a loop in a linked list
// without using extra memory.
let slow = head, fast = head;
while (fast?.next) {
  slow = slow.next;
  fast = fast.next.next;
  if (slow === fast) return true;
}
```

### Python

```python
# Kadane's algorithm — O(n) max subarray sum. Tracks the best sum ending at
# each index and the best overall seen so far.
best = current = nums[0]
for n in nums[1:]:
    current = max(n, current + n)
    best = max(best, current)
```

**Why it works:** naming the algorithm lets the reader look it up if they don't
know it, instead of reverse-engineering the loop.

---

## 6. Complex regex — GOOD

### TypeScript

```ts
// Match ISO-8601 dates with optional time and timezone suffix.
// YYYY-MM-DD(THH:MM:SS(.sss)?(Z|+HH:MM)?)?
const ISO_DATE = /^\d{4}-\d{2}-\d{2}(T\d{2}:\d{2}:\d{2}(\.\d{3})?(Z|[+-]\d{2}:\d{2})?)?$/;
```

### Python

```python
# Thai national ID: 13 digits, optional dashes. Accepts `1-2345-67890-12-3`
# and `1234567890123` interchangeably.
THAI_ID = re.compile(r'^(\d)-?(\d{4})-?(\d{5})-?(\d{2})-?(\d)$')
```

**Why it works:** regex is write-only by default. The comment gives the reader a
shape to match the pattern against.

---

## 7. Trade-off explanations — GOOD

### TypeScript

```ts
// Intentionally NOT using Promise.all — we need sequential execution so each
// request can reuse the auth token refreshed by the previous one.
for (const req of requests) {
  await send(req);
}
```

### Python

```python
# Pre-sort once instead of using heapq. N is always < 100 and sort reads cleaner;
# heapq only wins above ~10k elements.
items.sort(key=lambda x: x.priority)
```

**Why it works:** explains why the "obvious better" approach was rejected, so
nobody "optimizes" it into a bug later.

---

## 8. TODO / FIXME with context

### GOOD

```ts
// TODO(@friday, TICKET-2341): remove this fallback once all clients are on v2 API.
// Currently ~12% of traffic still hits v1 per analytics dashboard.
if (isV1Client(req)) return handleV1Fallback(req);
```

```python
# FIXME: race condition only appears under heavy load (>500 rps). See TICKET-4418
# — proper fix is to move this behind a Redis lock.
cache[key] = compute(key)
```

### BAD

```ts
// TODO: fix this
// TODO: refactor later
// FIXME: broken
```

No owner, no ticket, no context, no deadline. These rot in the codebase forever.

---

## 9. Cleanup — before and after

### Before (TypeScript, over-commented)

```ts
// User service class for managing users
export class UserService {
  // Repository for DB access
  constructor(private readonly repo: UserRepository) {}

  // Find a user by their ID
  // Returns the user or null if not found
  async findById(id: string): Promise<User | null> {
    // Call the repository to find the user
    return this.repo.findOne({ where: { id } });
  }

  // Delete a user by ID, but only if they're not an admin
  async deleteIfNotAdmin(id: string): Promise<void> {
    // Get the user first
    const user = await this.findById(id);
    // Check if user exists and is not admin
    if (user && user.role !== 'admin') {
      // Delete the user
      await this.repo.delete(id);
    }
  }
}
```

### After (cleaned up)

```ts
export class UserService {
  constructor(private readonly repo: UserRepository) {}

  async findById(id: string): Promise<User | null> {
    return this.repo.findOne({ where: { id } });
  }

  async deleteIfNotAdmin(id: string): Promise<void> {
    const user = await this.findById(id);
    if (user && user.role !== 'admin') {
      await this.repo.delete(id);
    }
  }
}
```

No comment was carrying real information — the names and types already explained
everything. All comments removed; readability improved.

### Before (Python, over-commented)

```python
# Function to process user orders
def process_orders(orders):
    # Empty list to hold results
    results = []
    # Loop through each order
    for order in orders:
        # Check if order is paid
        if order.status == 'paid':
            # Add it to results
            results.append(order)
    # Return the results
    return results
```

### After

```python
def get_paid_orders(orders: list[Order]) -> list[Order]:
    return [o for o in orders if o.status == 'paid']
```

Renamed the function to state intent, dropped the noise, and replaced the loop
with a list comprehension that reads like English.
