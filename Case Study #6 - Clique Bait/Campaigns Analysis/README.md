# Entity Relationship Diagram (ERD) for Clique Bait 🛠️

This section explains the Entity Relationship Diagram (ERD) for the **Clique Bait** case study. The ERD illustrates the relationships between the datasets used in this case study, providing a clear picture of how the data is structured and connected. 

---

## ERD Overview 📊
The database contains the following tables:

1. **Users** 👤
   - Tracks user information, including their unique identifier (`cookie_id`) and the date they joined.

2. **Events** 🗓️
   - Logs user interactions, including page views, cart additions, and purchases, along with sequence and timestamps.

3. **Event Identifier** 🔖
   - Maps event types to descriptive names (e.g., Page View, Purchase).

4. **Campaign Identifier** 🎯
   - Contains details about marketing campaigns, including their name, targeted products, and active dates.

5. **Page Hierarchy** 🗺️
   - Provides metadata about website pages, including product categories and associated product IDs.

---

## DBML Code for ERD 🔧
You can use the following **DBML** code to generate the ERD in tools like [DBDiagram.io](https://dbdiagram.io/):

```dbml
// Clique Bait Database Structure
// Docs: https://dbml.dbdiagram.io/docs

Table users {
  user_id integer [primary key]
  cookie_id varchar [note: 'Identifier for the user']
  start_date timestamp [note: 'Date the user joined']
}

Table events {
  visit_id varchar [note: 'Unique visit identifier']
  cookie_id varchar [note: 'Identifier for the user']
  page_id integer [note: 'ID of the page visited']
  event_type integer [note: 'Type of event']
  sequence_number integer [note: 'Sequence of events in the visit']
  event_time timestamp [note: 'Time of the event']

  Indexes {
    (visit_id, sequence_number) [unique]
  }
}

Table event_identifier {
  event_type integer [primary key, note: 'Unique event type identifier']
  event_name varchar [note: 'Name of the event']
}

Table campaign_identifier {
  campaign_id integer [primary key, note: 'Unique campaign identifier']
  products varchar [note: 'Targeted products in the campaign']
  campaign_name varchar [note: 'Name of the campaign']
  start_date timestamp [note: 'Campaign start date']
  end_date timestamp [note: 'Campaign end date']
}

Table page_hierarchy {
  page_id integer [primary key, note: 'Unique page identifier']
  page_name varchar [note: 'Name of the page']
  product_category varchar [note: 'Category of the product']
  product_id integer [note: 'Unique product identifier']
}

// Relationships
Ref: events.cookie_id > users.cookie_id
Ref: events.event_type > event_identifier.event_type
Ref: events.page_id > page_hierarchy.page_id
```

---

## Visualizing the ERD 🌟
You can create a visual representation of the database structure using the DBML code above. Simply paste it into [DBDiagram.io](https://dbdiagram.io/) to generate an interactive ERD.
![{53B2A3CD-F2AA-4F1E-80D8-3786BC800236}](https://github.com/user-attachments/assets/318af17e-e36b-4762-b94e-c3019557c9ff)

---

## Key Relationships 🔗
- **Users and Events**: `events.cookie_id` references `users.cookie_id`.
- **Events and Event Identifier**: `events.event_type` references `event_identifier.event_type`.
- **Events and Page Hierarchy**: `events.page_id` references `page_hierarchy.page_id`.

This structure ensures consistency and enables efficient querying across the datasets.

---

### Notes ✏️
- The `sequence_number` in the `events` table is used to maintain the chronological order of events for each visit.
- The `campaign_identifier` table links marketing efforts to specific products and timeframes, allowing for campaign performance analysis.

Happy querying! 🚀

