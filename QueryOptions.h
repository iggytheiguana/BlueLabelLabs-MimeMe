//
//  QueryOptions.h
//  Platform
//
//  Created by Bobby Gill on 10/10/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IJSONSerializable.h"

@interface QueryOptions : NSObject <IJSONSerializable> {
    BOOL        m_includelinkedobjects;
    NSString*   m_referencingattribute;
    NSString*   m_referencingobjecttype;
    int         m_maxlinksreturnedperobject;
    BOOL        m_linked_results_sortAscending;
    NSString*   m_linked_results_sortattribute;
    
    BOOL        m_primary_results_sortascending;
    NSString*   m_primary_results_sortattribute;
    
    int         m_clause_operator;
}


@property BOOL includelinkedobjects;
@property (nonatomic,retain) NSString* referencingattribute;
@property (nonatomic,retain) NSString* referencingobjecttype;
@property int maxlinksreturnedperobject;
@property BOOL linked_results_sortAscending;
@property (nonatomic,retain) NSString* linked_results_sortattribute;
@property (nonatomic, retain) NSString* primary_results_sortattribute;
@property BOOL primary_results_sortascending;
@property int   clause_operator;

- (NSString*)       toJSON;
- (NSDictionary*)   toDictionary;

//static initializers
+(QueryOptions*)queryForPhotos;
+(QueryOptions*)queryForPhotosInTheme;
+(QueryOptions*)queryForFeedsForUser:(NSNumber*)userID;
+(QueryOptions*)queryForCaptions:(NSNumber*)photoID;
+(QueryOptions*)queryForPages;
+(QueryOptions*)queryForUser:(NSNumber*)userID;
+(QueryOptions*)queryForDrafts;
+(QueryOptions*)queryForObjectIDs:(NSArray*)objectIDs withTypes:(NSArray*)objectTypes;
+(QueryOptions*)queryForApplicationSettings:(NSNumber*)userid;
+(QueryOptions*)queryForFollowers;
+(QueryOptions*)queryForFollowing;

//static initializers for mime-me
+(QueryOptions*)queryForFriends:(NSNumber*)userID;
+(QueryOptions*)queryForWords;
+(QueryOptions*)queryForSingleWord:(NSString*)word;
+(QueryOptions*)queryForMimeAnswersWithTarget:(NSNumber*)userid withState:(NSNumber*)state;
+(QueryOptions*)queryForStaffPickMimes;
+(QueryOptions*)queryForPublicMimes;
+(QueryOptions*)queryForFavoriteMimes:(NSNumber*)userid;
+(QueryOptions*) queryForMostRecentMimes;
+(QueryOptions*)queryForSentMimeAnswers:(NSNumber*)creatorid;
+(QueryOptions*)queryForSentMimes:(NSNumber*)creatorid;
+(QueryOptions*)queryForTopFavoritedMimes;
+(QueryOptions*)queryForMimeAnswersForMime:(NSNumber*)mimeid;
+(QueryOptions*)queryForComments:(NSNumber*)mimeid;
+(QueryOptions*)queryForUsersByFacebookID:(NSArray*)facebookids;
@end
