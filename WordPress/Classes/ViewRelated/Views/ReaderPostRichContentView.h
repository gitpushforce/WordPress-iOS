#import "ReaderPostContentView.h"
#import "WPRichContentView.h"

@interface ReaderPostRichContentView : ReaderPostContentView

@property (nonatomic, weak) id<ReaderPostContentViewDelegate, WPRichTextViewDelegate> delegate;

- (void)refreshMediaLayout;

@end
