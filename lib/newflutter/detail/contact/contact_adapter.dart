import 'package:flutter/material.dart';

import 'contact_info_model.dart' as ContactInfoModel;

class ContactAdapter extends StatelessWidget {
  final List<ContactInfoModel.ContactDTO> contacts;
  final Function(ContactInfoModel.ContactDTO) onItemClick;
  final bool isChild;

  const ContactAdapter({
    Key? key,
    required this.contacts,
    required this.onItemClick,
    this.isChild = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Text(
          'No contacts found',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contacts.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ContactItem(
          contact: contact,
          onTap: () => onItemClick(contact),
        );
      },
    );
  }
}

class ContactItem extends StatelessWidget {
  final ContactInfoModel.ContactDTO contact;
  final VoidCallback onTap;

  const ContactItem({
    Key? key,
    required this.contact,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 头像
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF262626),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      contact.relation,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // 手机号
              Text(
                contact.mobile,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF409EFF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}